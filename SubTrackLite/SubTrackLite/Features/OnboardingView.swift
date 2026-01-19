//
//  OnboardingView.swift
//  SubTrackLite
//
//  Redesigned: "The Briefing"
//  Editorial, Calm, Trustworthy.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        TabView {
            // Page 1: Clarity
            OnboardingPage(
                title: "Financial\nClarity.",
                description: "Stop the monthly drain. See exactly where your money goes, all in one calm place.",
                icon: "eye.fill", // Simple, abstract
                isLastPage: false,
                action: nil
            )
            
            // Page 2: Control
            OnboardingPage(
                title: "Quiet\nControl.",
                description: "Get notified before you pay. Cancel unwanted subscriptions with zero stress.",
                icon: "shield.fill",
                isLastPage: true,
                action: {
                    container.notificationScheduler.requestAuthorization()
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(DesignSystem.Colors.background)
        .ignoresSafeArea()
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let icon: String
    let isLastPage: Bool
    let action: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            // Icon - subtle, minimalist
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(DesignSystem.Colors.tint)
                .padding(.bottom, DesignSystem.Layout.spacingL)
                .opacity(0.8)
            
            // Editorial Title
            Text(title)
                .font(DesignSystem.Typography.editorialLarge())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .lineSpacing(4)
                .padding(.bottom, DesignSystem.Layout.spacingM)
            
            // Body Copy
            Text(description)
                .font(DesignSystem.Typography.body())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .lineSpacing(6)
                .padding(.trailing, 40) // Meaningful whitespace on right
            
            Spacer()
            Spacer()
            
            // Action Area
            if isLastPage {
                Button(action: { action?() }) {
                    Text("Begin Briefing")
                        .bold()
                }
                .stylePrimaryButton()
                .padding(.bottom, DesignSystem.Layout.spacingXL)
            } else {
                HStack {
                    Text("Swipe to continue")
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    Spacer()
                }
                .padding(.bottom, DesignSystem.Layout.spacingXL)
            }
        }
        .padding(.horizontal, DesignSystem.Layout.spacingXL)
        .padding(.top, 60)
    }
}
