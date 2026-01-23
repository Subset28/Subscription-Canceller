//
//  DesignSystem.swift
//  SubTrackLite
//
//  Created by Antigravity on 2026-01-19.
//  Camille Mormal / Leo Natsume Inspiration: Warm, soft, organic, editorial.
//

import SwiftUI

struct DesignSystem {
    
    // MARK: - Colors
    // MARK: - Colors
    struct Colors {
        // Helper for Light/Dark mode support
        private static func adaptiveColor(light: Color, dark: Color) -> Color {
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
            })
        }
        
        // Primary Brand: Deep Slate (Light) / Soft Indigo (Dark)
        static let primary = adaptiveColor(
            light: Color(red: 0.25, green: 0.25, blue: 0.35),
            dark: Color(red: 0.36, green: 0.36, blue: 0.90) // Soft Indigo
        )
        
        // Background: Paper (Light) / Deep Charcoal (Dark)
        static let background = adaptiveColor(
            light: Color(red: 0.98, green: 0.98, blue: 0.976),
            dark: Color(red: 0.07, green: 0.07, blue: 0.07) // Almost Black #121212
        )
        
        // Cards: White (Light) / Elevated Grey (Dark)
        static let cardBackground = adaptiveColor(
            light: Color.white,
            dark: Color(red: 0.11, green: 0.11, blue: 0.118) // #1E1E1E
        )
        
        // Text: Soft Charcoal (Light) / Off-White (Dark)
        static let textPrimary = adaptiveColor(
            light: Color(red: 0.1, green: 0.1, blue: 0.12),
            dark: Color(red: 0.95, green: 0.95, blue: 0.97)
        )
        
        // Secondary Text
        static let textSecondary = adaptiveColor(
            light: Color(red: 0.4, green: 0.4, blue: 0.45),
            dark: Color(red: 0.68, green: 0.68, blue: 0.7)
        )
        
        // Tertiary Text
        static let textTertiary = adaptiveColor(
            light: Color(red: 0.6, green: 0.6, blue: 0.65),
            dark: Color(red: 0.4, green: 0.4, blue: 0.45)
        )
        
        // Semantic
        static let tint = adaptiveColor(
            light: Color(red: 0.35, green: 0.4, blue: 0.9),
            dark: Color(red: 0.4, green: 0.5, blue: 1.0) // Brighter Blue
        )
        
        static let success = adaptiveColor(
            light: Color(red: 0.25, green: 0.5, blue: 0.35),
            dark: Color(red: 0.4, green: 0.8, blue: 0.5) // Brighter Green
        )
        
        static let warning = adaptiveColor(
            light: Color(red: 0.85, green: 0.55, blue: 0.25),
            dark: Color(red: 1.0, green: 0.7, blue: 0.3) // Brighter Amber
        )
        
        static let critical = adaptiveColor(
            light: Color(red: 0.8, green: 0.3, blue: 0.3),
            dark: Color(red: 1.0, green: 0.4, blue: 0.4) // Brighter Red
        )
    }
    
    // MARK: - Typography
    struct Typography {
        
        // Editorial Headings: Serif (New York)
        // Used for "Total Monthly", Onboarding Titles, Major Section Headers
        static func editorialLarge() -> Font {
            .system(size: 34, weight: .bold, design: .serif)
        }
        
        static func editorialTitle() -> Font {
            .system(size: 24, weight: .semibold, design: .serif)
        }
        
        // Technical/Functional: Sans-Serif (SF Pro / Rounded)
        // Used for numbers, prices, dates, small labels
        static func largeTitle() -> Font { .largeTitle.weight(.bold) }
        static func title() -> Font { .title2.weight(.bold) }
        static func headline() -> Font { .headline.weight(.semibold) }
        static func body() -> Font { .body }
        static func subheadline() -> Font { .subheadline }
        static func caption() -> Font { .caption }
        
        // Currency: Always rounded for that friendly financial feel
        static func currencyBig() -> Font {
            .system(size: 40, weight: .semibold, design: .rounded)
        }
        
        static func currency() -> Font {
            .system(.title3, design: .rounded).weight(.semibold)
        }
    }
    
    // MARK: - Layout
    struct Layout {
        static let spacingXS: CGFloat = 4
        static let spacingS: CGFloat = 8
        static let spacingM: CGFloat = 16
        static let spacingL: CGFloat = 24
        static let spacingXL: CGFloat = 32
        static let spacingXXL: CGFloat = 48
        static let spacingXXXL: CGFloat = 64 // Generous white space
        
        static let cornerRadiusS: CGFloat = 8
        static let cornerRadiusM: CGFloat = 16 // Softer corners
        static let cornerRadiusL: CGFloat = 24
        static let cornerRadiusXL: CGFloat = 32
    }
    
    // MARK: - Shadows
    struct Shadows {
        // Very subtle, diffuse shadows. Not rigid.
        static func soft(color: Color = Color.black) -> some ViewModifier {
            ShadowModifier(color: color.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        
        static func float(color: Color = Color.black) -> some ViewModifier {
            ShadowModifier(color: color.opacity(0.1), radius: 20, x: 0, y: 10)
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
            .foregroundStyle(DesignSystem.Colors.background)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL)
                    .fill(DesignSystem.Colors.textPrimary) // Solid dark button
            )
            .modifier(DesignSystem.Shadows.soft(color: DesignSystem.Colors.textPrimary))
    }
    
    func styleSecondaryButton() -> some View {
        self.font(DesignSystem.Typography.headline())
            .foregroundStyle(DesignSystem.Colors.textPrimary)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL)
                    .fill(Color.white)
            )
            .modifier(DesignSystem.Shadows.soft())
    }
    
    func styleCard() -> some View {
        self.background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusM))
            .modifier(DesignSystem.Shadows.soft())
    }
}
