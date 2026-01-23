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
    @State private var syncToCalendar = false // Calendar Sync State
    
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
                        
                        Spacer()
                    }
                } header: {
                    Text("Organization")
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
                            
                            if container.entitlementManager.isSmartRemindersUnlocked {
                                Text("7 days before").tag(7)
                                Text("14 days before").tag(14)
                            } else {
                                Text("7 days before (Premium)").tag(7).foregroundStyle(.secondary)
                            }
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
                    
                    // Calendar Sync (Premium)
                    if container.entitlementManager.canSyncToCalendar {
                        Toggle("Sync to Apple Calendar", isOn: $syncToCalendar)
                            .onChange(of: syncToCalendar) {
                                if syncToCalendar {
                                    // Request Access Immediately
                                    Task {
                                        let granted = await container.calendarService.requestAccess()
                                        if !granted {
                                            syncToCalendar = false
                                        }
                                    }
                                }
                            }
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Text("Sync to Apple Calendar")
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(DesignSystem.Colors.tint)
                            }
                        }
                    }
                    
                        TextField("Cancellation URL (optional)", text: $cancelURL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        // Email Concierge Link (Premium Only)
                        if container.entitlementManager.isConciergeUnlocked {
                            NavigationLink {
                                EmailConciergeView(serviceName: name.isEmpty ? "Service Provider" : name)
                            } label: {
                                Label("Draft Cancellation Email", systemImage: "envelope")
                                    .font(.caption)
                                    .foregroundStyle(DesignSystem.Colors.tint)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Label("Draft Cancellation Email", systemImage: "envelope")
                                        .font(.caption)
                                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(DesignSystem.Colors.tint)
                                }
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
                        Task { await saveSubscription() }
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
        syncToCalendar = subscription.calendarEventID != nil
    }
    
    private func saveSubscription() async {
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
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfSelected = calendar.startOfDay(for: nextRenewalDate)
        
        if startOfSelected < startOfToday {
            validationMessage = "Renewal date must be in the future. Please check your bill."
            showingValidationAlert = true
            return
        }
        
        let adjustedRenewalDate = nextRenewalDate
        var subscriptionToProcess: Subscription!
        
        // 1. Perform SwiftData Operations (Main Actor)
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
            
            // Handle Calendar Sync (Update or Remove logic later)
            // We just update the model here.
            subscriptionToProcess = existingSubscription
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
                calendarEventID: nil, // Will be set after insertion if sync is on
                notes: notes.isEmpty ? nil : notes
            )
            
            modelContext.insert(newSubscription)
            subscriptionToProcess = newSubscription
        }
        
        // 2. Save Context (Main Actor)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
            // If save fails, we shouldn't proceed with services
            return
        }
        
        // 3. Create DTO (Thread Safe Snapshot)
        // MUST be done after save so ID is permanent and state is consistent
        var dto = SubscriptionDTO(from: subscriptionToProcess)
        
        // 4. Perform Service Operations (Async / Background Safe)
        
        // Calendar Sync
        if syncToCalendar {
            if let id = await container.calendarService.addOrUpdateEvent(for: dto) {
                // Update model with new ID
                subscriptionToProcess.calendarEventID = id
                // Update DTO if needed for further steps, though ID is just for local storage usually
            }
        } else if let eventID = subscriptionToProcess.calendarEventID {
             // User turned OFF sync, remove event
             await container.calendarService.removeEvent(identifier: eventID)
             subscriptionToProcess.calendarEventID = nil
        }
        
        // Save again if calendar ID changed
        if subscriptionToProcess.hasChanges {
             try? modelContext.save()
             // Refresh DTO
             dto = SubscriptionDTO(from: subscriptionToProcess)
        }

        // Notifications & Spotlight (Use DTO)
        // NotificationScheduler is MainActor but using DTO is safer against implicit property access faults
        container.notificationScheduler.updateNotification(for: dto)
        container.spotlightService.index(dto)
        
        dismiss()
    }
}

