//
//  StickyHeader.swift
//  SubTrackLite
//
//  Created by Antigravity on 2026-01-19.
//  Redesigned as "The Briefing" - Bold, Editorial, Clear.
//

import SwiftUI

struct StickyHeader: View {
    let subscriptions: [Subscription]
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Layout.spacingM) {
            
            // Header Label
            Text("Monthly Commitments")
                .font(DesignSystem.Typography.editorialTitle())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            
            // Big Number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(totalMonthly)
                    .font(DesignSystem.Typography.currencyBig())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text("/ mo")
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
            
            Divider()
                .overlay(DesignSystem.Colors.textTertiary.opacity(0.2))
            
            // Secondary Stat (Yearly)
            HStack {
                Text("Yearly projection")
                    .font(DesignSystem.Typography.subheadline())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Text(totalYearly)
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
        }
        .padding(DesignSystem.Layout.spacingL)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL))
        .modifier(DesignSystem.Shadows.float()) // Slightly more elevation for the "Master" card
        .padding(.horizontal, DesignSystem.Layout.spacingM)
        .padding(.top, DesignSystem.Layout.spacingM)
        .padding(.bottom, DesignSystem.Layout.spacingS)
    }
    
    private var totalMonthly: String {
        container.currencyFormatter.formatTotal(subscriptions, period: .monthly)
    }
    
    private var totalYearly: String {
        container.currencyFormatter.formatTotal(subscriptions, period: .yearly)
    }
}
