//
//  SubTrackLiteApp.swift
//  SubTrackLite
//
//  A minimal, offline-first subscription tracker with local notifications.
//

import SwiftUI
import SwiftData

@main
struct SubTrackLiteApp: App {
    @StateObject private var container = DependencyContainer()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .modelContainer(container.modelContainer)
                .onAppear {
                    container.notificationScheduler.requestAuthorization()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                container.notificationScheduler.refreshScheduledNotifications()
            }
        }
    }
}

// MARK: - Content View (Root Navigation)
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            SubscriptionListView()
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}
