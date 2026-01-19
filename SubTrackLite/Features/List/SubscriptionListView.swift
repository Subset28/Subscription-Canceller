//
//  SubscriptionListView.swift
//  SubTrackLite
//
//  Main subscription list with filtering, search, and summary totals
//

import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var container: DependencyContainer
    @Query(sort: \Subscription.nextRenewalDate) private var allSubscriptions: [Subscription]
    
    @State private var searchText = ""
    @State private var filterOption: FilterOption = .all
    @State private var showingAddSubscription = false
    @State private var showingSettings = false
    
    private var filteredSubscriptions: [Subscription] {
        var subs = allSubscriptions
        
        // Apply search filter
        if !searchText.isEmpty {
            subs = subs.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply time filter
        switch filterOption {
        case .all:
            break
        case .sevenDays:
            subs = subs.filter { $0.isRenewingWithin(days: 7) }
        case .thirtyDays:
            subs = subs.filter { $0.isRenewingWithin(days: 30) }
        }
        
        return subs
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if allSubscriptions.isEmpty {
                    emptyStateView
                } else {
                    listContent
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                EditSubscriptionView(subscription: nil)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private var listContent: some View {
        List {
            // Summary section
            Section {
                SummaryCard(subscriptions: allSubscriptions)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Filter picker
            Section {
                Picker("Filter", selection: $filterOption) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            
            // Subscriptions list
            Section {
                ForEach(filteredSubscriptions) { subscription in
                    NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                        SubscriptionRow(subscription: subscription)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteSubscription(subscription)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Edit action
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search subscriptions")
        .listStyle(.insetGrouped)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("No Subscriptions Yet")
                .font(.title2.bold())
            
            Text("Add your first subscription to track renewals and never miss a payment.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddSubscription = true
            } label: {
                Label("Add Subscription", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func deleteSubscription(_ subscription: Subscription) {
        container.notificationScheduler.cancelNotification(for: subscription)
        modelContext.delete(subscription)
        try? modelContext.save()
    }
}

// MARK: - Filter Option
enum FilterOption: String, CaseIterable {
    case all = "All"
    case sevenDays = "7 Days"
    case thirtyDays = "30 Days"
    
    var displayName: String { rawValue }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let subscriptions: [Subscription]
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(container.currencyFormatter.formatTotal(subscriptions, period: .monthly))
                        .font(.title2.bold())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Yearly")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(container.currencyFormatter.formatTotal(subscriptions, period: .yearly))
                        .font(.title2.bold())
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Subscription Row
struct SubscriptionRow: View {
    let subscription: Subscription
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon placeholder
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(subscription.name.prefix(1).uppercased()))
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(container.currencyFormatter.format(subscription.price, currencyCode: subscription.currencyCode))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("·")
                        .foregroundStyle(.secondary)
                    
                    Text(subscription.billingPeriod.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.nextRenewalDate, style: .date)
                    .font(.subheadline.bold())
                
                if subscription.daysUntilRenewal >= 0 {
                    Text(daysUntilText)
                        .font(.caption)
                        .foregroundStyle(daysUntilColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var daysUntilText: String {
        let days = subscription.daysUntilRenewal
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "in \(days) days"
        }
    }
    
    private var daysUntilColor: Color {
        let days = subscription.daysUntilRenewal
        if days <= 3 {
            return .red
        } else if days <= 7 {
            return .orange
        } else {
            return .secondary
        }
    }
}

#Preview {
    SubscriptionListView()
        .environmentObject(DependencyContainer())
}
