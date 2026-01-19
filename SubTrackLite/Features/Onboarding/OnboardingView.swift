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
    
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Value Proposition
            OnboardingPage1()
                .tag(0)
            
            // Page 2: Privacy + Notifications
            OnboardingPage2(
                hasCompletedOnboarding: $hasCompletedOnboarding,
                requestNotifications: {
                    container.notificationScheduler.requestAuthorization()
                }
            )
            .tag(1)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// MARK: - Page 1
struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 100))
                .foregroundStyle(.blue.gradient)
            
            VStack(spacing: 16) {
                Text("Never Forget a Renewal")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text("Track all your subscriptions in one place and get reminded before renewals.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Text("Swipe to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Page 2
struct OnboardingPage2: View {
    @Binding var hasCompletedOnboarding: Bool
    let requestNotifications: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                FeatureBadge(
                    icon: "lock.shield",
                    title: "Private & Offline",
                    description: "No account, no tracking. All data stays on your device."
                )
                
                FeatureBadge(
                    icon: "bell.badge",
                    title: "Smart Reminders",
                    description: "Get notified before renewals so you're never caught off guard."
                )
                
                FeatureBadge(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Spending",
                    description: "See your total monthly and yearly subscription costs."
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    requestNotifications()
                    hasCompletedOnboarding = true
                } label: {
                    Text("Enable Notifications & Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("Skip for Now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Feature Badge
struct FeatureBadge: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .environmentObject(DependencyContainer())
}
