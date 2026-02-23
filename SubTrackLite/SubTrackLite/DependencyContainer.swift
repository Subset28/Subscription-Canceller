//
//  DependencyContainer.swift
//  SubTrackLite
//
//  Lightweight dependency injection container
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class DependencyContainer: ObservableObject {
    let modelContainer: ModelContainer
    let notificationScheduler: NotificationScheduler
    let currencyFormatter: CurrencyFormatter
    let csvExportService: CSVExportService
    let entitlementManager: EntitlementManager
    let adManager: AdManager
    let calendarService: CalendarService
    let spotlightService: SpotlightService
    
    init() {
        // Initialize SwiftData model container
        do {
            let schema = Schema([Subscription.self])
            // Use a specific store URL to ensure a clean slate (Fixes infinite crash loop due to schema mismatch)
            // V3: Reset due to BillingPeriod serialization change (Keyed -> SingleValue)
            // V4: Flattened BillingPeriod (Deep Fix) - Enum removed from persistence
            let url = URL.documentsDirectory.appending(path: "SubTrackLite_v4.store")
            let config = ModelConfiguration(url: url)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("DependencyContainer: Failed to initialize persistent model container: \(error.localizedDescription)")
            print("DependencyContainer: Falling back to in-memory storage to prevent crash.")
            do {
                let schema = Schema([Subscription.self])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("DependencyContainer: Critical Failure. Could not initialize in-memory container: \(error.localizedDescription)")
            }
        }
        
        // Initialize services
        notificationScheduler = NotificationScheduler()
        currencyFormatter = CurrencyFormatter()
        csvExportService = CSVExportService()
        entitlementManager = EntitlementManager()
        adManager = AdManager()
        calendarService = CalendarService()
        spotlightService = SpotlightService.shared
    }
}
