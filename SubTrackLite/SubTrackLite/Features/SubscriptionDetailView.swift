//
//  SubscriptionDetailView.swift
//  SubTrackLite
//
//  Detailed view of a single subscription with upcoming renewals and cancellation info
//

import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: DependencyContainer
    
    let subscription: Subscription
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            // Main Info Section
            Section {
                DetailRow(label: "Name", value: subscription.name)
                DetailRow(
                    label: "Price",
                    value: container.currencyFormatter.format(subscription.price, currencyCode: subscription.currencyCode)
                )
                DetailRow(label: "Billing Period", value: subscription.billingPeriod.displayName)
                DetailRow(label: "Next Renewal", value: subscription.nextRenewalDate.formatted(date: .long, time: .omitted))
                
                if subscription.daysUntilRenewal >= 0 {
                    DetailRow(
                        label: "Days Until Renewal",
                        value: "\(subscription.daysUntilRenewal)",
                        valueColor: subscription.daysUntilRenewal <= 7 ? .red : .primary
                    )
                }
            } header: {
                Text("Subscription Details")
            }
            
            // Upcoming Renewals
            Section {
                ForEach(Array(subscription.upcomingRenewalDates().enumerated()), id: \.offset) { index, date in
                    HStack {
                        Text("Renewal \(index + 1)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            } header: {
                Text("Upcoming Renewals")
            }
            
            // Reminder Settings
            Section {
                HStack {
                    Text("Reminders Enabled")
                    Spacer()
                    Text(subscription.remindersEnabled ? "Yes" : "No")
                        .foregroundStyle(.secondary)
                }
                
                if subscription.remindersEnabled {
                    HStack {
                        Text("Remind Me")
                        Spacer()
                        Text("\(subscription.reminderLeadTimeDays) days before")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Notifications")
            }
            
            // Cost Summary
            Section {
                DetailRow(
                    label: "Monthly Cost",
                    value: container.currencyFormatter.format(subscription.estimatedMonthlyCost, currencyCode: subscription.currencyCode)
                )
                DetailRow(
                    label: "Yearly Cost",
                    value: container.currencyFormatter.format(subscription.estimatedYearlyCost, currencyCode: subscription.currencyCode)
                )
            } header: {
                Text("Cost Estimates")
            } footer: {
                Text("Estimates are calculated based on the billing period.")
            }
            
            // How to Cancel
            Section {
                if subscription.isAppleSubscription {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This is an Apple subscription. To cancel:")
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Open Settings on your device")
                            Text("2. Tap your name at the top")
                            Text("3. Tap Subscriptions")
                            Text("4. Select \(subscription.name)")
                            Text("5. Tap Cancel Subscription")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("To cancel this subscription:")
                            .font(.subheadline)
                        
                        if let cancelURL = subscription.cancelURLAsURL {
                            Link(destination: cancelURL) {
                                Label("Open Cancellation Page", systemImage: "arrow.up.right.square")
                            }
                        } else {
                            Text("Visit the service's website or app and navigate to account settings to manage your subscription.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                if let notes = subscription.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes:")
                            .font(.subheadline.bold())
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            } header: {
                Text("How to Cancel")
            }
            
            // Actions
            Section {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit Subscription", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Subscription", systemImage: "trash")
                }
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditSubscriptionView(subscription: subscription)
        }
        .alert("Delete Subscription", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSubscription()
            }
        } message: {
            Text("Are you sure you want to delete \(subscription.name)? This action cannot be undone.")
        }
    }
    
    private func deleteSubscription() {
        // Create DTO for services
        let dto = SubscriptionDTO(from: subscription)
        container.notificationScheduler.cancelNotification(for: dto)
        container.spotlightService.deindex(dto)
        modelContext.delete(subscription)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
        }
    }
}
