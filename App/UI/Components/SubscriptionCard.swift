//
//  SubscriptionCard.swift
//  SubTrackLite
//
//  Created by Antigravity on 2026-01-19.
//

import SwiftUI

struct SubscriptionCard: View {
    let subscription: Subscription
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        HStack(spacing: DesignSystem.Layout.spacingM) {
            // Icon / Logo Placeholder
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.tint.opacity(0.15))
                
                Text(String(subscription.name.prefix(1).uppercased()))
                    .font(DesignSystem.Typography.title())
                    .foregroundStyle(DesignSystem.Colors.tint)
            }
            .frame(width: 52, height: 52)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(container.currencyFormatter.format(subscription.price, currencyCode: subscription.currencyCode))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                    
                    Text("/")
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    
                    Text(subscription.billingPeriod.displayName)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .font(DesignSystem.Typography.subheadline())
            }
            
            Spacer()
            
            // Renewal Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(daysUntilText)
                    .font(DesignSystem.Typography.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(daysUntilColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(daysUntilColor.opacity(0.1))
                    .clipShape(Capsule())
                
                Text(subscription.nextRenewalDate, style: .date)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
        }
        .padding()
        .styleCard()
    }
    
    private var daysUntilText: String {
        let days = subscription.daysUntilRenewal
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "In \(days) days"
        }
    }
    
    private var daysUntilColor: Color {
        let days = subscription.daysUntilRenewal
        if days <= 3 {
            return DesignSystem.Colors.critical
        } else if days <= 7 {
            return DesignSystem.Colors.warning
        } else {
            return DesignSystem.Colors.textSecondary
        }
    }
}
