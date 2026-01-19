//
//  StickyHeader.swift
//  SubTrackLite
//
//  Created by Antigravity on 2026-01-19.
//

import SwiftUI

struct StickyHeader: View {
    let subscriptions: [Subscription]
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        HStack(spacing: 0) {
            // Monthly
            summaryItem(
                title: "Monthly",
                amount: container.currencyFormatter.formatTotal(subscriptions, period: .monthly)
            )
            
            Divider()
                .frame(height: 40)
                .padding(.horizontal, DesignSystem.Layout.spacingM)
            
            // Yearly
            summaryItem(
                title: "Yearly",
                amount: container.currencyFormatter.formatTotal(subscriptions, period: .yearly)
            )
        }
        .padding()
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL))
        .modifier(DesignSystem.Shadows.soft())
        .padding(.horizontal)
        .padding(.top, DesignSystem.Layout.spacingS)
        .padding(.bottom, DesignSystem.Layout.spacingS)
    }
    
    private func summaryItem(title: String, amount: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(DesignSystem.Typography.caption())
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.textTertiary)
                .tracking(1) // Letter spacing
            
            Text(amount)
                .font(DesignSystem.Typography.title())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
