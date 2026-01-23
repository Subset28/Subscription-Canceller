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
    
    @State private var isSplashActive = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(container)
                    .modelContainer(container.modelContainer)
                    .onAppear {
                        container.notificationScheduler.requestAuthorization()
                    }
                
                if isSplashActive {
                    SplashView(isActive: $isSplashActive)
                }
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
    @State private var selectedTab = 0
    
    var body: some View {
        if hasCompletedOnboarding {
            TabView(selection: $selectedTab) {
                // Tab 1: Dashboard
                SubscriptionListView()
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2.fill")
                    }
                    .tag(0)
                
                // Tab 2: Calendar
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(1)
                
                // Tab 3: Insights ("Spending DNA")
                InsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "chart.pie.fill")
                    }
                    .tag(2)
                
                // Tab 4: Settings (Moved from Sheet)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(DesignSystem.Colors.tint)
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}
