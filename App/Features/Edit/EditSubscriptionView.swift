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
    @State private var reminderLeadTimeDays = 3
    @State private var remindersEnabled = true
    @State private var isAppleSubscription = false
    @State private var cancelURL = ""
    @State private var notes = ""
    
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    private var isEditing: Bool { subscription != nil }
    private var title: String { isEditing ? "Edit Subscription" : "Add Subscription" }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                    
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
                    
                    if !isAppleSubscription {
                        TextField("Cancellation URL (optional)", text: $cancelURL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
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
        }
    }
    
    private func loadSubscriptionData() {
        guard let subscription = subscription else { return }
        
        name = subscription.name
        price = "\(subscription.price)"
        billingPeriod = subscription.billingPeriod
        nextRenewalDate = subscription.nextRenewalDate
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
        
        // Auto-adjust past renewal dates
        let adjustedRenewalDate: Date
        if nextRenewalDate < Date() {
            // Move to next valid cycle
            var testDate = nextRenewalDate
            while testDate < Date() {
                testDate = billingPeriod.nextRenewalDate(from: testDate)
            }
            adjustedRenewalDate = testDate
        } else {
            adjustedRenewalDate = nextRenewalDate
        }
        
        if isEditing, let existingSubscription = subscription {
            // Update existing
            existingSubscription.name = name.trimmingCharacters(in: .whitespaces)
            existingSubscription.price = priceDecimal
            existingSubscription.billingPeriod = billingPeriod
            existingSubscription.nextRenewalDate = adjustedRenewalDate
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
}

#Preview {
    EditSubscriptionView(subscription: nil)
        .environmentObject(DependencyContainer())
}
