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
                // Background
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                if allSubscriptions.isEmpty {
                    emptyStateView
                } else {
                    mainContent
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
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
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Sticky Header of Totals
            StickyHeader(subscriptions: allSubscriptions)
                .padding(.bottom, DesignSystem.Layout.spacingS)
            
            // Filter Picker
            Picker("Filter", selection: $filterOption) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, DesignSystem.Layout.spacingM)
            
            // List
            List {
                ForEach(filteredSubscriptions) { subscription in
                    ZStack {
                        // Navigation Link Hack to hide the chevron but keep interaction
                        NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        SubscriptionCard(subscription: subscription)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: DesignSystem.Layout.spacingS / 2,
                        leading: DesignSystem.Layout.spacingM,
                        bottom: DesignSystem.Layout.spacingS / 2,
                        trailing: DesignSystem.Layout.spacingM
                    ))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteSubscription(subscription)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Edit action provided by NavigationLink usually, but we can add shortcut
                             // Ideally we navigate to edit, but `SubscriptionDetailView` has edit button.
                             // We can leave acts as Delete mostly.
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(DesignSystem.Colors.tint)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            // Ad Placeholder (Future Proofing)
            Color.clear
                .frame(height: 50) // Standard banner height
                .listRowBackground(Color.clear)
        }
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "calendar.badge.clock",
            title: "Never forget a subscription again.",
            message: "Track recurring payments, get reminders, and see where your money goes.",
            actionTitle: "Add your first subscription",
            action: {
                showingAddSubscription = true
            }
        )
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

#Preview {
    SubscriptionListView()
        .environmentObject(DependencyContainer())
}
