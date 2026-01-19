//
//  EmptyStateView.swift
//  SubTrackLite
//
//  Redesigned: "The Blank Slate"
//  Calm, encouraging, not empty.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String // Kept for API compatibility, but might override
    let title: String
    let message: String // Kept for API compatibility
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Minimal Icon
            Image(systemName: "plus.square.dashed") // More abstract "Add" vibe
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(DesignSystem.Colors.textTertiary)
                .padding(.bottom, DesignSystem.Layout.spacingL)
            
            // Editorial Headline
            Text("Your ledger is clean.")
                .font(DesignSystem.Typography.editorialTitle())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .padding(.bottom, DesignSystem.Layout.spacingS)
            
            // Reassuring Body
            Text("Add your first subscription to start tracking.\nYour clarity begins here.")
                .font(DesignSystem.Typography.body())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Primary Action
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .stylePrimaryButton()
                .padding(.horizontal, DesignSystem.Layout.spacingL)
                .padding(.bottom, DesignSystem.Layout.spacingXXL)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background) // Ensure paper texture
    }
}
