//
//  AppTheme.swift
//  SubTrackLite
//
//  Centralized theme constants and styling (Legacy Support via DesignSystem)
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let primaryAccent = DesignSystem.Colors.tint
    static let warningColor = DesignSystem.Colors.warning
    static let dangerColor = DesignSystem.Colors.critical
    static let successColor = DesignSystem.Colors.success
    
    // MARK: - Spacing
    static let paddingSmall = DesignSystem.Layout.spacingS
    static let paddingMedium = DesignSystem.Layout.spacingM
    static let paddingLarge = DesignSystem.Layout.spacingL
    
    // MARK: - Corner Radius
    static let cornerRadiusSmall = DesignSystem.Layout.cornerRadiusS
    static let cornerRadiusMedium = DesignSystem.Layout.cornerRadiusM
    static let cornerRadiusLarge = DesignSystem.Layout.cornerRadiusL
    
    // MARK: - Shadows
    static let shadowLight = Color.black.opacity(0.05)
    static let shadowMedium = Color.black.opacity(0.1)
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = DesignSystem.Typography.largeTitle()
        static let title = DesignSystem.Typography.title()
        static let headline = DesignSystem.Typography.headline()
        static let body = DesignSystem.Typography.body()
        static let caption = DesignSystem.Typography.caption()
    }
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .styleCard()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline())
            .foregroundStyle(DesignSystem.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
