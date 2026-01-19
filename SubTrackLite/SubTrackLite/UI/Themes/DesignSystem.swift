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
    struct Colors {
        // Primary Brand: A deep, muted indigo that feels intelligent, not techy.
        static let primary = Color(red: 0.25, green: 0.25, blue: 0.35) // Deep Slate
        
        // Background: "Paper" / "Stone". Warm, inviting, non-digital.
        // #FAFAF9 -> RGB(250, 250, 249)
        static let background = Color(red: 0.98, green: 0.98, blue: 0.976)
        
        // Cards: Pure white to pop against the warm background.
        static let cardBackground = Color.white
        
        // Text: Never pure black.
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.12) // Soft Charcoal
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.45) // Muted Grey
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.65) // Light Grey
        
        // Semantic
        static let tint = Color(red: 0.35, green: 0.4, blue: 0.9) // Soft Royal Blue
        static let success = Color(red: 0.25, green: 0.5, blue: 0.35) // Sage Green
        static let warning = Color(red: 0.85, green: 0.55, blue: 0.25) // Muted Amber
        static let critical = Color(red: 0.8, green: 0.3, blue: 0.3) // Brick Red
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
            .foregroundStyle(.white)
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
