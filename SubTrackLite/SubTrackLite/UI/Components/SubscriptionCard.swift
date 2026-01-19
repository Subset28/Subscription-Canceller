//
//  SubscriptionCard.swift
//  SubTrackLite
//
//  Created by Antigravity on 2026-01-19.
//  Minimalist, spacious, clean.
//

import SwiftUI

struct SubscriptionCard: View {
    let subscription: Subscription
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Layout.spacingM) {
            
            // Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.background) // Subtle contrast
                    .frame(width: 48, height: 48)
                
                Text(String(subscription.name.prefix(1).uppercased()))
                    .font(DesignSystem.Typography.title())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(subscription.name)
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(container.currencyFormatter.format(subscription.price, currencyCode: subscription.currencyCode))
                        .font(DesignSystem.Typography.currency())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
                
                HStack(alignment: .center) {
                    Text(subscription.billingPeriod.displayName)
                        .font(DesignSystem.Typography.subheadline())
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    
                    Spacer()
                    
                    // Days Until Pill
                    Text(daysUntilText)
                        .font(DesignSystem.Typography.caption())
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(daysUntilColor.opacity(0.1))
                        )
                        .foregroundStyle(daysUntilColor)
                }
            }
            .padding(.top, 2) // Optical alignment with icon
        }
        .padding(DesignSystem.Layout.spacingL) // Generous internal padding
        .styleCard()
    }
    
    private var daysUntilText: String {
        let days = subscription.daysUntilRenewal
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "in \(days)d"
    }
    
    private var daysUntilColor: Color {
        let days = subscription.daysUntilRenewal
        if days <= 3 { return DesignSystem.Colors.critical }
        if days <= 7 { return DesignSystem.Colors.warning }
        return DesignSystem.Colors.textTertiary
    }
}
