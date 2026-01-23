//
//  InsightsView.swift
//  SubTrackLite
//
//  "Spending DNA" - Visual breakdown of subscription costs by category.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @EnvironmentObject private var container: DependencyContainer
    @Query(sort: \Subscription.price, order: .reverse) private var subscriptions: [Subscription]
    
    // Process data for charts
    private var categoryData: [CategoryTotal] {
        let grouped = Dictionary(grouping: subscriptions, by: { $0.category })
        return grouped.map { key, value in
            let total = value.reduce(0) { $0 + ($1.price * $1.billingPeriod.monthlyMultiplier) }
            return CategoryTotal(category: key, amount: total, count: value.count)
        }.sorted { $0.amount > $1.amount }
    }
    
    private var monthlyTotal: Decimal {
        subscriptions.reduce(0) { $0 + ($1.price * $1.billingPeriod.monthlyMultiplier) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Layout.spacingL) {
                    
                    // 1. Total Spend Header
                    VStack(spacing: 8) {
                        Text("Monthly Spend")
                            .font(DesignSystem.Typography.subheadline())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        
                        Text(container.currencyFormatter.format(monthlyTotal, currencyCode: "USD"))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Layout.spacingL)
                    
                    // 2. Spending DNA (Chart)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Spending DNA")
                            .font(DesignSystem.Typography.headline())
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal)
                        
                        if subscriptions.isEmpty {
                            EmptyStateView(
                                icon: "chart.pie",
                                title: "No Data",
                                message: "Add subscriptions to see your spending breakdown.",
                                actionTitle: nil,
                                action: nil
                            )
                            .padding()
                        } else {
                            Chart(categoryData) { item in
                                SectorMark(
                                    angle: .value("Amount", item.amount),
                                    innerRadius: .ratio(0.618),
                                    angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("Category", item.category.rawValue))
                            }
                            .frame(height: 250)
                            .padding(.horizontal)
                        }
                    }
                    
                    // 3. Category Breakdown List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Breakdown")
                            .font(DesignSystem.Typography.headline())
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(categoryData) { item in
                                HStack {
                                    Image(systemName: item.category.icon)
                                        .font(.system(size: 16))
                                        .frame(width: 32, height: 32)
                                        .background(DesignSystem.Colors.tint.opacity(0.1))
                                        .foregroundStyle(DesignSystem.Colors.tint)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.category.rawValue)
                                            .font(DesignSystem.Typography.body(isBold: true))
                                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                                        
                                        Text("\(item.count) subscriptions")
                                            .font(DesignSystem.Typography.caption())
                                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(container.currencyFormatter.format(item.amount, currencyCode: "USD"))
                                        .font(DesignSystem.Typography.body(isBold: true))
                                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                                }
                                .padding()
                                .background(DesignSystem.Colors.cardBackground)
                                
                                if item.id != categoryData.last?.id {
                                    Divider().padding(.leading, 64)
                                }
                            }
                        }
                        .cornerRadius(DesignSystem.Layout.cornerRadiusL)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 4. Top Expenses
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Top Expenses")
                            .font(DesignSystem.Typography.headline())
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(subscriptions.prefix(3)) { sub in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: sub.category.icon)
                                                .font(.caption)
                                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                            Spacer()
                                            Text(sub.billingPeriod.displayName)
                                                .font(.caption2)
                                                .foregroundStyle(DesignSystem.Colors.textTertiary)
                                                .textCase(.uppercase)
                                        }
                                        
                                        Text(sub.name)
                                            .font(DesignSystem.Typography.body(isBold: true))
                                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text(container.currencyFormatter.format(sub.price, currencyCode: sub.currencyCode))
                                            .font(DesignSystem.Typography.headline())
                                            .foregroundStyle(DesignSystem.Colors.tint)
                                    }
                                    .padding()
                                    .frame(width: 140)
                                    .background(DesignSystem.Colors.cardBackground)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(DesignSystem.Colors.background.ignoresSafeArea())
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CategoryTotal: Identifiable {
    var id: String { category.rawValue }
    let category: SubscriptionCategory
    let amount: Decimal
    let count: Int
}
