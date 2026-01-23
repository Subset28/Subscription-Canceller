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
                        if container.entitlementManager.products.isEmpty {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .padding()
                                
                                Button("Retry Loading") {
                                    Task { await container.entitlementManager.loadProducts() }
                                }
                                .font(DesignSystem.Typography.subheadline())
                                .foregroundStyle(DesignSystem.Colors.tint)
                                
                                Text("If this persists, check Xcode:\nProduct > Scheme > Edit Scheme > Options\nEnsure StoreKit Configuration is 'Unsub'")
                                    .font(DesignSystem.Typography.caption())
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                                    .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: DesignSystem.Layout.spacingM) {
                                ForEach(container.entitlementManager.products) { product in
                                    Button {
                                        purchase(product: product)
                                    } label: {
                                        PricingButtonContent(
                                            title: product.displayName,
                                            price: product.displayPrice,
                                            subtitle: product.description,
                                            isHighlighted: product.id.contains("yearly") // Highlight annual
                                        )
                                    }
                                }
                                
                                Text("Restore Purchases")
                                    .font(DesignSystem.Typography.caption())
                                    .underline()
                                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                                    .onTapGesture {
                                        restore()
                                    }
                                    .padding(.top, DesignSystem.Layout.spacingS)
                                
                                // Rewarded Ad Option
                                Button {
                                    watchAdToEarn()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.tv.fill")
                                        Text("Watch Ad to Add +1 Slot")
                                    }
                                    .font(DesignSystem.Typography.subheadline())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .stroke(DesignSystem.Colors.textSecondary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .padding(.top, DesignSystem.Layout.spacingM)
                            }
                            .padding(.horizontal, DesignSystem.Layout.spacingM)
                            .padding(.bottom, DesignSystem.Layout.spacingXL)
                        }
                    }
                }
            }
            .onAppear {
                AnalyticsService.shared.log(.paywallViewed)
                // Retry loading products if they haven't loaded yet
                if container.entitlementManager.products.isEmpty {
                    Task {
                        await container.entitlementManager.loadProducts()
                    }
                }
            }
        }
    }
    
    private func watchAdToEarn() {
        container.adManager.showRewardedAd {
            // Reward Verified
            container.entitlementManager.rewardUserWithSlot()
            dismiss() // Close paywall so they can add their sub
        }
    }
    
    private func purchase(product: Product) {
        isPurchasing = true
        Task {
            do {
                try await container.entitlementManager.purchase(product)
                isPurchasing = false
                dismiss()
            } catch {
                isPurchasing = false
                print("Purchase failed: \(error)")
            }
        }
    }
    
    private func restore() {
        Task {
            await container.entitlementManager.restorePurchases()
        }
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
                    .foregroundStyle(isHighlighted ? DesignSystem.Colors.cardBackground : DesignSystem.Colors.textPrimary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(isHighlighted ? DesignSystem.Colors.cardBackground.opacity(0.8) : DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            Text(price)
                .font(DesignSystem.Typography.title()) // Bold price
                .foregroundStyle(isHighlighted ? DesignSystem.Colors.cardBackground : DesignSystem.Colors.textPrimary)
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
