//
//  InsightsView.swift
//  SubTrackLite
//
//  Premium "Spending DNA" visualizations using Swift Charts.
//

import SwiftUI
import Charts
import SwiftData

struct InsightsView: View {
    @Query private var subscriptions: [Subscription]
    @EnvironmentObject private var container: DependencyContainer
    @Environment(\.dismiss) private var dismiss
    
    // Compute category breakdown
    private var categoryData: [(category: String, amount: Decimal)] {
        let grouped = Dictionary(grouping: subscriptions, by: { $0.categoryRaw })
        return grouped.map { key, subs in
            let total = subs.reduce(0) { $0 + $1.estimatedMonthlyCost }
            return (category: key, amount: total)
        }.sorted { $0.amount > $1.amount }
    }
    
    private var totalMonthlySpend: Decimal {
        subscriptions.reduce(0) { $0 + $1.estimatedMonthlyCost }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                if subscriptions.isEmpty {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.pie",
                        description: Text("Add subscriptions to see your spending DNA.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Layout.spacingL) {
                            
                            // 1. Hero Total
                            VStack(spacing: 8) {
                                Text("Monthly Spend")
                                    .font(DesignSystem.Typography.subheadline())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                                
                                Text(container.currencyFormatter.format(totalMonthlySpend))
                                    .font(DesignSystem.Typography.editorialLarge())
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                            }
                            .padding(.top, DesignSystem.Layout.spacingM)
                            
                            // 1.5 Key Metrics Grid (Buffed Insights)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    InsightMetricCard(
                                        title: "Yearly Projection",
                                        value: container.currencyFormatter.format(totalMonthlySpend * 12),
                                        icon: "calendar.badge.clock"
                                    )
                                    
                                    if let highest = subscriptions.max(by: { $0.estimatedMonthlyCost < $1.estimatedMonthlyCost }) {
                                        InsightMetricCard(
                                            title: "Highest Sub",
                                            value: container.currencyFormatter.format(highest.estimatedMonthlyCost),
                                            subtitle: highest.name,
                                            icon: "arrow.up.forward.circle.fill",
                                            iconColor: .orange
                                        )
                                    }
                                    
                                    if !subscriptions.isEmpty {
                                        let average = totalMonthlySpend / Decimal(subscriptions.count)
                                        InsightMetricCard(
                                            title: "Average Cost",
                                            value: container.currencyFormatter.format(average),
                                            icon: "divide.circle.fill",
                                            iconColor: .blue
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // 2. Spending DNA (Donut Chart)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Spending DNA")
                                    .font(DesignSystem.Typography.headline())
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                
                                Chart(categoryData, id: \.category) { item in
                                    SectorMark(
                                        angle: .value("Spend", item.amount),
                                        innerRadius: .ratio(0.618),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(by: .value("Category", item.category))
                                }
                                .frame(height: 250)
                                .chartBackground { proxy in
                                    GeometryReader { geo in
                                        if let topCategory = categoryData.first {
                                            VStack(spacing: 4) {
                                                Text("Top Spend")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                Text(topCategory.category)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                Text(container.currencyFormatter.format(topCategory.amount))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL)
                                    .fill(DesignSystem.Colors.cardBackground)
                                    .modifier(DesignSystem.Shadows.soft())
                            )
                            .padding(.horizontal)
                            
                            // 3. Top Expenses List
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Top Expenses")
                                    .font(DesignSystem.Typography.headline())
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    ForEach(subscriptions.sorted(by: { $0.estimatedMonthlyCost > $1.estimatedMonthlyCost }).prefix(5)) { sub in
                                        HStack {
                                            Text(sub.name)
                                                .font(DesignSystem.Typography.body())
                                            Spacer()
                                            Text(container.currencyFormatter.format(sub.estimatedMonthlyCost))
                                                .font(DesignSystem.Typography.body().bold())
                                        }
                                        .padding()
                                        
                                        if sub.id != subscriptions.sorted(by: { $0.estimatedMonthlyCost > $1.estimatedMonthlyCost }).prefix(5).last?.id {
                                            Divider().padding(.leading)
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL)
                                        .fill(DesignSystem.Colors.cardBackground)
                                        .modifier(DesignSystem.Shadows.soft())
                                )
                                .padding(.horizontal)
                            }
                            
                            // Disclaimer
                            Text("Estimates based on billing period calculations.")
                                .font(.caption)
                                .foregroundStyle(DesignSystem.Colors.textTertiary)
                                .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Toolbar items removed for Tab context
            }
        }
    }
}

struct InsightMetricCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var icon: String? = nil
    var iconColor: Color = DesignSystem.Colors.tint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.title3)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(width: 140, height: 110)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.Layout.cornerRadiusM)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
