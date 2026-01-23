//
//  Subscription.swift
//  SubTrackLite
//
//  SwiftData model for a subscription entity
//

import Foundation
import SwiftData

@Model
final class Subscription {
    @Attribute(.unique) var id: UUID
    var name: String
    var price: Decimal
    var currencyCode: String
    var billingPeriod: BillingPeriod
    var nextRenewalDate: Date
    var reminderLeadTimeDays: Int
    var remindersEnabled: Bool
    var isAppleSubscription: Bool
    var cancelURL: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Organization (New)
    var categoryRaw: String = "Personal"
    
    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .personal }
        set { categoryRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Decimal,
        currencyCode: String = Locale.current.currency?.identifier ?? "USD",
        billingPeriod: BillingPeriod,
        nextRenewalDate: Date,
        category: SubscriptionCategory = .personal,
        reminderLeadTimeDays: Int = 3,
        remindersEnabled: Bool = true,
        isAppleSubscription: Bool = false,
        cancelURL: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.currencyCode = currencyCode
        self.billingPeriod = billingPeriod
        self.nextRenewalDate = nextRenewalDate
        self.categoryRaw = category.rawValue
        self.reminderLeadTimeDays = reminderLeadTimeDays
        self.remindersEnabled = remindersEnabled
        self.isAppleSubscription = isAppleSubscription
        self.cancelURL = cancelURL
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var notificationIdentifier: String {
        "subscription-\(id.uuidString)"
    }
    
    var cancelURLAsURL: URL? {
        guard let urlString = cancelURL else { return nil }
        return URL(string: urlString)
    }
    
    func updateRenewalDate() {
        updatedAt = Date()
    }
}

// MARK: - Enums

enum SubscriptionCategory: String, Codable, CaseIterable, Sendable {
    case personal = "Personal"
    case business = "Business"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case trials = "Trials"
    
    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .business: return "briefcase.fill"
        case .entertainment: return "tv.fill"
        case .utilities: return "bolt.fill"
        case .trials: return "clock.arrow.circlepath"
        }
    }
}

// MARK: - Extensions

extension Subscription {
    // Calculate next N renewal dates
    func upcomingRenewalDates(count: Int = 3) -> [Date] {
        var dates: [Date] = []
        var currentDate = nextRenewalDate
        
        for _ in 0..<count {
            dates.append(currentDate)
            currentDate = billingPeriod.nextRenewalDate(from: currentDate)
        }
        
        return dates
    }
    
    // Convert to estimated monthly cost
    var estimatedMonthlyCost: Decimal {
        price * billingPeriod.monthlyMultiplier
    }
    
    // Convert to estimated yearly cost
    var estimatedYearlyCost: Decimal {
        estimatedMonthlyCost * 12
    }
    
    // Days until next renewal
    var daysUntilRenewal: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let renewal = calendar.startOfDay(for: nextRenewalDate)
        let components = calendar.dateComponents([.day], from: now, to: renewal)
        return components.day ?? 0
    }
    
    // Check if renewal is within N days
    func isRenewingWithin(days: Int) -> Bool {
        return daysUntilRenewal <= days && daysUntilRenewal >= 0
    }
}
