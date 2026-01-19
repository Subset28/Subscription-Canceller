//
//  BillingPeriod.swift
//  SubTrackLite
//
//  Enum representing subscription billing cycles
//

import Foundation

enum BillingPeriod: Codable, Sendable, Hashable {
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
