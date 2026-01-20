//
//  SubscriptionListView.swift
//  SubTrackLite
//
//  Redesigned: "The Dashboard"
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
    @State private var showingPaywall = false
    @State private var showingSettings = false
    
    // Computed filtering
    private var filteredSubscriptions: [Subscription] {
        var subs = allSubscriptions
        // Search
        if !searchText.isEmpty {
            subs = subs.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        // Time Filter
        switch filterOption {
        case .all: break
        case .sevenDays: subs = subs.filter { $0.isRenewingWithin(days: 7) }
        case .thirtyDays: subs = subs.filter { $0.isRenewingWithin(days: 30) }
        }
        return subs
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Global "Paper" Background
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                if allSubscriptions.isEmpty {
                    emptyStateView
                } else {
                    mainContent
                }
            }
            .navigationTitle("Briefing")
            .navigationBarTitleDisplayMode(.large) // "Briefing" looks good large
            .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
            .toolbar {
                // Leading: Settings
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    }
                }
                
                // Trailing: Add + Filter Menu
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $filterOption) {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: filterOption == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    }
                    
                    Button {
                        if container.entitlementManager.canAddSubscription(currentCount: allSubscriptions.count) {
                            showingAddSubscription = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                EditSubscriptionView(subscription: nil)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .searchable(text: $searchText, prompt: "Search ledger")
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Layout.spacingM) {
                
                // The "Briefing" Dashboard Card
                // Only show if we aren't searching/filtering heavily, or always show?
                // Always showing is better for "Cost Awareness"
                if searchText.isEmpty {
                    StickyHeader(subscriptions: allSubscriptions)
                        .padding(.bottom, DesignSystem.Layout.spacingS)
                }
                
                // List of Cards
                LazyVStack(spacing: DesignSystem.Layout.spacingM) {
                    ForEach(Array(filteredSubscriptions.enumerated()), id: \.element.id) { index, subscription in
                        // Card Interaction
                        ZStack {
                            NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            SubscriptionCard(subscription: subscription)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteSubscription(subscription)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .padding(.horizontal, DesignSystem.Layout.spacingM) // Screen margins
                        
                        // Inject Ad after 2nd item (index 1)
                        if index == 1 && !container.entitlementManager.hasPremiumAccess {
                            NativeAdCard(adManager: container.adManager)
                                .padding(.horizontal, DesignSystem.Layout.spacingM)
                        }
                    }
                }
                
                // Future Ads Placeholder (Subtle)
                Color.clear.frame(height: 60)
            }
            .padding(.vertical, DesignSystem.Layout.spacingS)
        }
        .scrollIndicators(.hidden)
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "plus.square.dashed",
            title: "Your ledger is clean.",
            message: "Add your first subscription to start tracking.",
            actionTitle: "Add Entry",
            action: { showingAddSubscription = true }
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
    case all = "All Entries"
    case sevenDays = "Next 7 Days"
    case thirtyDays = "Next 30 Days"
    
    var displayName: String { rawValue }
}
