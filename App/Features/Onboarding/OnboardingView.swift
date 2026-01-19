//
//  OnboardingView.swift
//  SubTrackLite
//
//  Minimal 2-screen onboarding focused on value and privacy
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var container: DependencyContainer
    
    var body: some View {
        TabView {
            // Screen 1: The Problem & Solution
            OnboardingPage(
                icon: "creditcard.trianglebadge.exclamationmark",
                title: "Where is your money going?",
                description: "Subscriptions pile up quietly. Take back control and stop the monthly drain.",
                isLastPage: false,
                action: nil
            )
            
            // Screen 2: The Peace of Mind
            OnboardingPage(
                icon: "bell.badge.wavelines",
                title: "Never get surprised.",
                description: "Get notified before you pay. Cancel what you don't use. Local, private, and secure.",
                isLastPage: true,
                action: {
                    container.notificationScheduler.requestAuthorization()
                    hasCompletedOnboarding = true
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
    let icon: String
    let title: String
    let description: String
    let isLastPage: Bool
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: DesignSystem.Layout.spacingXL) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.textPrimary.opacity(0.05))
                    .frame(width: 140, height: 140)
                    .modifier(DesignSystem.Shadows.soft())
                
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundStyle(DesignSystem.Colors.tint)
            }
            .padding(.bottom, DesignSystem.Layout.spacingM)
            
            // Text
            VStack(spacing: DesignSystem.Layout.spacingM) {
                Text(title)
                    .font(DesignSystem.Typography.largeTitle())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(description)
                    .font(DesignSystem.Typography.title()) // Slightly smaller than large title
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.horizontal, DesignSystem.Layout.spacingXL)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            if isLastPage {
                Button(action: { action?() }) {
                    Text("Start Saving Money")
                        .font(DesignSystem.Typography.headline())
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .stylePrimaryButton()
                .padding(.horizontal, DesignSystem.Layout.spacingL)
                .padding(.bottom, 60) // Space for page indicator
            } else {
                Text("Swipe to continue")
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                    .padding(.bottom, 60)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .environmentObject(DependencyContainer())
}
