//
//  EmptyStateView.swift
//  SubTrackLite
//
//  Reusable empty state component
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Layout.spacingL) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.background)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(DesignSystem.Colors.tint)
            }
            .padding(.bottom, DesignSystem.Layout.spacingM)
            
            // Text
            VStack(spacing: DesignSystem.Layout.spacingS) {
                Text(title)
                    .font(DesignSystem.Typography.title())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(message)
                    .font(DesignSystem.Typography.body())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Layout.spacingXL)
            }
            
            Spacer()
            
            // Action
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: "plus")
                        Text(actionTitle)
                    }
                }
                .stylePrimaryButton()
                .padding(.horizontal, DesignSystem.Layout.spacingL)
                .padding(.bottom, DesignSystem.Layout.spacingXL)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

#Preview {
    EmptyStateView(
        icon: "calendar.badge.clock",
        title: "No Subscriptions",
        message: "Add your first subscription to get started",
        actionTitle: "Add Subscription",
        action: {}
    )
}
