//
//  DependencyContainer.swift
//  SubTrackLite
//
//  Lightweight dependency injection container
//

import Foundation
import SwiftData

@MainActor
class DependencyContainer: ObservableObject {
    let modelContainer: ModelContainer
    let notificationScheduler: NotificationScheduler
    let currencyFormatter: CurrencyFormatter
    let csvExportService: CSVExportService
    let entitlementManager: EntitlementManager
    
    init() {
        // Initialize SwiftData model container
        do {
            let schema = Schema([Subscription.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize model container: \(error.localizedDescription)")
        }
        
        // Initialize services
        notificationScheduler = NotificationScheduler()
        currencyFormatter = CurrencyFormatter()
        csvExportService = CSVExportService()
        entitlementManager = EntitlementManager()
    }
}
