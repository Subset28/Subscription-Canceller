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
    var cancelURL: String? // Store as String, convert to URL when needed
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Decimal,
        currencyCode: String = Locale.current.currency?.identifier ?? "USD",
        billingPeriod: BillingPeriod,
        nextRenewalDate: Date,
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
        self.reminderLeadTimeDays = reminderLeadTimeDays
        self.remindersEnabled = remindersEnabled
        self.isAppleSubscription = isAppleSubscription
        self.cancelURL = cancelURL
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Computed properties
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

// MARK: - Billing Period
enum BillingPeriod: Codable, CaseIterable {
    case weekly
    case monthly
    case quarterly
    case yearly
    case custom(days: Int)
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        case .custom(let days): return "\(days) Days"
        }
    }
    
    var daysInPeriod: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 30 // Approximation
        case .quarterly: return 91 // Approximation
        case .yearly: return 365
        case .custom(let days): return days
        }
    }
    
    // Standard cases for picker
    static var standardCases: [BillingPeriod] {
        [.weekly, .monthly, .quarterly, .yearly]
    }
    
    // Calculate next renewal date from a given date
    func nextRenewalDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .custom(let days):
            return calendar.date(byAdding: .day, value: days, to: date) ?? date
        }
    }
    
    // Convert to monthly cost multiplier
    var monthlyMultiplier: Decimal {
        switch self {
        case .weekly:
            return Decimal(52) / Decimal(12) // ~4.33
        case .monthly:
            return 1
        case .quarterly:
            return Decimal(1) / Decimal(3) // ~0.33
        case .yearly:
            return Decimal(1) / Decimal(12) // ~0.083
        case .custom(let days):
            return Decimal(30) / Decimal(days)
        }
    }
}

// MARK: - Subscription Extensions
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
