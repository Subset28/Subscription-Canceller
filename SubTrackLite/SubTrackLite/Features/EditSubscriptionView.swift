//
//  EditSubscriptionView.swift
//  SubTrackLite
//
//  Add or edit a subscription with validation
//

import SwiftUI
import SwiftData

struct EditSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: DependencyContainer
    
    let subscription: Subscription?
    
    @State private var name = ""
    @State private var price = ""
    @State private var billingPeriod: BillingPeriod = .monthly
    @State private var nextRenewalDate = Date()
    @State private var category: SubscriptionCategory = .personal
    @State private var reminderLeadTimeDays = 3
    @State private var remindersEnabled = true
    @State private var isAppleSubscription = false
    @State private var cancelURL = ""
    @State private var notes = ""
    
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingPaywall = false
    
    private var isEditing: Bool { subscription != nil }
    private var title: String { isEditing ? "Edit Subscription" : "Add Subscription" }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { oldValue, newValue in
                            if let foundURL = ServiceCatalog.getCancelURL(for: newValue), cancelURL.isEmpty {
                                cancelURL = foundURL
                            }
                        }
                    
                    HStack {
                        Text(Locale.current.currency?.identifier ?? "USD")
                            .foregroundStyle(.secondary)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("Basic Information")
                }
                
                Section {
                    HStack {
                        Picker("Category", selection: $category) {
                            ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                            }
                        }
                        .disabled(!container.entitlementManager.isCategoryUnlocked)
                        
                        if !container.entitlementManager.isCategoryUnlocked {
                            Button {
                                showingPaywall = true
                            } label: {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(DesignSystem.Colors.tint)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Organization")
                } footer: {
                    if !container.entitlementManager.isCategoryUnlocked {
                        Text("Upgrade to Premium to create custom categories.")
                            .font(.caption)
                            .foregroundStyle(DesignSystem.Colors.tint)
                    }
                }
                
                Section {
                    Picker("Billing Period", selection: $billingPeriod) {
                        ForEach(BillingPeriod.standardCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    
                    DatePicker(
                        "Next Renewal Date",
                        selection: $nextRenewalDate,
                        displayedComponents: .date
                    )
                } header: {
                    Text("Billing Details")
                }
                
                Section {
                    Toggle("Enable Reminders", isOn: $remindersEnabled)
                    
                    if remindersEnabled {
                        Picker("Remind Me", selection: $reminderLeadTimeDays) {
                            Text("1 day before").tag(1)
                            Text("3 days before").tag(3)
                            Text("7 days before").tag(7)
                            Text("14 days before").tag(14)
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    if remindersEnabled && container.notificationScheduler.authorizationStatus != .authorized {
                        Text("Notifications are not enabled. Please enable them in Settings to receive reminders.")
                            .foregroundStyle(.orange)
                    }
                }
                
                Section {
                    Toggle("Apple Subscription", isOn: $isAppleSubscription)
                    
                        TextField("Cancellation URL (optional)", text: $cancelURL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        // Email Concierge Link
                        NavigationLink {
                            EmailConciergeView(serviceName: name.isEmpty ? "Service Provider" : name)
                        } label: {
                            Label("Draft Cancellation Email", systemImage: "envelope")
                                .font(.caption)
                                .foregroundStyle(DesignSystem.Colors.tint)
                        }
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Additional Information")
                }
                
                // Preview section
                if !name.isEmpty && !price.isEmpty {
                    Section {
                        HStack {
                            Text("Monthly Cost")
                            Spacer()
                            if let priceDecimal = Decimal(string: price) {
                                let monthlyCost = priceDecimal * billingPeriod.monthlyMultiplier
                                Text(container.currencyFormatter.format(monthlyCost))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Yearly Cost")
                            Spacer()
                            if let priceDecimal = Decimal(string: price) {
                                let yearlyCost = priceDecimal * billingPeriod.monthlyMultiplier * 12
                                Text(container.currencyFormatter.format(yearlyCost))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("Cost Preview")
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                }
            }
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                loadSubscriptionData()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    private func loadSubscriptionData() {
        guard let subscription = subscription else { return }
        
        name = subscription.name
        price = "\(subscription.price)"
        billingPeriod = subscription.billingPeriod
        nextRenewalDate = subscription.nextRenewalDate
        category = subscription.category
        reminderLeadTimeDays = subscription.reminderLeadTimeDays
        remindersEnabled = subscription.remindersEnabled
        isAppleSubscription = subscription.isAppleSubscription
        cancelURL = subscription.cancelURL ?? ""
        notes = subscription.notes ?? ""
    }
    
    private func saveSubscription() {
        // Validate
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter a name for the subscription."
            showingValidationAlert = true
            return
        }
        
        guard let priceDecimal = Decimal(string: price), priceDecimal >= 0 else {
            validationMessage = "Please enter a valid price (0 or greater)."
            showingValidationAlert = true
            return
        }
        
        // Prevent illogical reminders (e.g. 7 day reminder for Weekly)
        if billingPeriod == .weekly && reminderLeadTimeDays >= 7 {
            validationMessage = "For weekly subscriptions, the reminder must be less than 7 days."
            showingValidationAlert = true
            return
        }
        
        // Enforce Future Dates (Strict Mode)
        // User Requirement: "Enforce future-only renewal dates (no past dates allowed)"
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfSelected = calendar.startOfDay(for: nextRenewalDate)
        
        if startOfSelected < startOfToday {
            validationMessage = "Renewal date must be in the future. Please check your bill."
            showingValidationAlert = true
            return
        }
        
        let adjustedRenewalDate = nextRenewalDate
        
        if isEditing, let existingSubscription = subscription {
            // Update existing
            existingSubscription.name = name.trimmingCharacters(in: .whitespaces)
            existingSubscription.price = priceDecimal
            existingSubscription.billingPeriod = billingPeriod
            existingSubscription.nextRenewalDate = adjustedRenewalDate
            existingSubscription.category = category
            existingSubscription.reminderLeadTimeDays = reminderLeadTimeDays
            existingSubscription.remindersEnabled = remindersEnabled
            existingSubscription.isAppleSubscription = isAppleSubscription
            existingSubscription.cancelURL = cancelURL.isEmpty ? nil : cancelURL
            existingSubscription.notes = notes.isEmpty ? nil : notes
            existingSubscription.updateRenewalDate()
            
            container.notificationScheduler.updateNotification(for: existingSubscription)
        } else {
            // Create new
            let newSubscription = Subscription(
                name: name.trimmingCharacters(in: .whitespaces),
                price: priceDecimal,
                billingPeriod: billingPeriod,
                nextRenewalDate: adjustedRenewalDate,
                category: category,
                reminderLeadTimeDays: reminderLeadTimeDays,
                remindersEnabled: remindersEnabled,
                isAppleSubscription: isAppleSubscription,
                cancelURL: cancelURL.isEmpty ? nil : cancelURL,
                notes: notes.isEmpty ? nil : notes
            )
            
            modelContext.insert(newSubscription)
            container.notificationScheduler.scheduleNotification(for: newSubscription)
        }
        
        try? modelContext.save()
        dismiss()
    }

