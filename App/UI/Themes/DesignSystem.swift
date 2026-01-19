//
//  DesignSystem.swift
//  SubTrackLite
//
//  Created by Antigravity on 2026-01-19.
//

import SwiftUI

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.indigo
        static let background = Color(.systemGroupedBackground)
        static let secondaryBackground = Color(.secondarySystemGroupedBackground)
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(.tertiaryLabel)
        
        static let success = Color.green
        static let warning = Color.orange
        static let critical = Color.red
        
        static let tint = Color.indigo
    }
    
    // MARK: - Typography
    struct Typography {
        static func largeTitle() -> Font { .largeTitle.weight(.bold) }
        static func title() -> Font { .title2.weight(.bold) } // Slightly smaller title for cards
        static func headline() -> Font { .headline.weight(.semibold) }
        static func body() -> Font { .body }
        static func subheadline() -> Font { .subheadline }
        static func caption() -> Font { .caption }
        
        // Monetary values often look better monospaced or bounded
        static func currency() -> Font { .system(.title3, design: .rounded).weight(.semibold) }
    }
    
    // MARK: - Layout
    struct Layout {
        static let spacingXS: CGFloat = 4
        static let spacingS: CGFloat = 8
        static let spacingM: CGFloat = 16
        static let spacingL: CGFloat = 24
        static let spacingXL: CGFloat = 32
        static let spacingXXL: CGFloat = 48
        
        static let cornerRadiusS: CGFloat = 8
        static let cornerRadiusM: CGFloat = 12
        static let cornerRadiusL: CGFloat = 16
        static let cornerRadiusXL: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        static func soft(color: Color = Color.black) -> some ViewModifier {
            ShadowModifier(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        
        static func float(color: Color = Color.black) -> some ViewModifier {
            ShadowModifier(color: color.opacity(0.12), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: - View Modifiers
struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Extensions
extension View {
    func stylePrimaryButton() -> some View {
        self.font(DesignSystem.Typography.headline())
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusM))
    }
    
    func styleSecondaryButton() -> some View {
        self.font(DesignSystem.Typography.headline())
            .foregroundStyle(DesignSystem.Colors.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusM))
    }
    
    func styleCard() -> some View {
        self.background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusM))
            .modifier(DesignSystem.Shadows.soft())
    }
}
