//  PaywallView.swift
//  SubTrackLite
//
//  High-conversion, premium upsell screen.
//  "Unsub" - Financial Bodyguard framing.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: DependencyContainer
    
    // State for purchasing (stubbed for now)
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Close Button (Subtle, top right)
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(DesignSystem.Colors.textTertiary)
                            .padding(12)
                            .background(Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, DesignSystem.Layout.spacingM)
                .padding(.top, DesignSystem.Layout.spacingM)
                
                ScrollView {
                    VStack(spacing: DesignSystem.Layout.spacingL) {
                        
                        // 2. Emotional Hero
                        VStack(spacing: DesignSystem.Layout.spacingM) {
                            Image(systemName: "shield.check.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .shadow(color: DesignSystem.Colors.textPrimary.opacity(0.2), radius: 20, x: 0, y: 10)
                            
                            Text("Unsub\nPremium")
                                .font(DesignSystem.Typography.editorialLarge())
                                .multilineTextAlignment(.center)
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            
                            Text("Stop the leaks. Protect your wallet.\nUnlock the ultimate financial bodyguard.")
                                .font(DesignSystem.Typography.body())
                                .multilineTextAlignment(.center)
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, DesignSystem.Layout.spacingL)
                        
                        // 3. Value Props (The "Feature Gating")
                        VStack(alignment: .leading, spacing: DesignSystem.Layout.spacingM) {
                            FeatureRow(icon: "infinity", title: "Unlimited Subscriptions", subtitle: "Track everything, no limits.")
                            FeatureRow(icon: "bell.badge.fill", title: "Guardian Notifications", subtitle: "Get alerted before you pay.")
                            FeatureRow(icon: "arrow.down.doc.fill", title: "Data Export", subtitle: "Your data is yours. CSV ready.")
                        }
                        .padding(.horizontal, DesignSystem.Layout.spacingL)
                        .padding(.vertical, DesignSystem.Layout.spacingM)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusL)
                                .fill(DesignSystem.Colors.cardBackground)
                                .modifier(DesignSystem.Shadows.soft())
                        )
                        .padding(.horizontal, DesignSystem.Layout.spacingM)
                        
                        // 4. Pricing Options
                        VStack(spacing: DesignSystem.Layout.spacingM) {
                            // Annual (Best Value)
                            Button {
                                purchase(productID: "com.subtrack.lite.premium.yearly")
                            } label: {
                                PricingButtonContent(
                                    title: "Annual Protection",
                                    price: "$19.99 / year",
                                    subtitle: "Just $1.66 / month. Save 50%.",
                                    isHighlighted: true
                                )
                            }
                            
                            // Weekly (Impulse)
                            Button {
                                purchase(productID: "com.subtrack.lite.premium.weekly")
                            } label: {
                                PricingButtonContent(
                                    title: "Weekly Pass",
                                    price: "$1.99 / week",
                                    subtitle: "Cancel anytime.",
                                    isHighlighted: false
                                )
                            }
                            
                            Text("Restore Purchases")
                                .font(DesignSystem.Typography.caption())
                                .underline()
                                .foregroundStyle(DesignSystem.Colors.textTertiary)
                                .onTapGesture {
                                    restore()
                                }
                                .padding(.top, DesignSystem.Layout.spacingS)
                        }
                        .padding(.horizontal, DesignSystem.Layout.spacingM)
                        .padding(.bottom, DesignSystem.Layout.spacingXL)
                    }
                }
            }
        }
    }
    
    private func purchase(productID: String) {
        // Stub for now. Connection to EntitlementManager comes later.
        isPurchasing = true
        // Simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPurchasing = false
            dismiss()
            // In real app, we'd call EntitlementManager.purchase()
        }
    }
    
    private func restore() {
        // Stub
    }
}

// MARK: - Components
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Layout.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 20)) // Fixed size for alignment
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.subheadline())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

struct PricingButtonContent: View {
    let title: String
    let price: String
    let subtitle: String
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(isHighlighted ? .white : DesignSystem.Colors.textPrimary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(isHighlighted ? .white.opacity(0.8) : DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            Text(price)
                .font(DesignSystem.Typography.title()) // Bold price
                .foregroundStyle(isHighlighted ? .white : DesignSystem.Colors.textPrimary)
        }
        .padding(DesignSystem.Layout.spacingM)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusM)
                .fill(isHighlighted ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadiusM)
                        .stroke(DesignSystem.Colors.textPrimary.opacity(0.1), lineWidth: isHighlighted ? 0 : 1)
                )
                .modifier(DesignSystem.Shadows.soft())
        )
    }
}
