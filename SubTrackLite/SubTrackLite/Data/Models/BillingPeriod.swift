//
//  BillingPeriod.swift
//  SubTrackLite
//
//  Enum representing subscription billing cycles
//

import Foundation

enum BillingPeriod: Codable, Sendable, Hashable {
    case weekly
    case biweekly
    case monthly
    case quarterly
    case semiannual
    case yearly
    case custom(days: Int)
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .biweekly: return "Bi-Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .semiannual: return "Semi-Annual"
        case .yearly: return "Yearly"
        case .custom(let days): return "\(days) Days"
        }
    }
    
    var daysInPeriod: Int {
        switch self {
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30 // Approximation
        case .quarterly: return 91 // Approximation
        case .semiannual: return 182 // Approximation
        case .yearly: return 365
        case .custom(let days): return days
        }
    }
    
    // Standard cases for picker
    static var standardCases: [BillingPeriod] {
        [.weekly, .biweekly, .monthly, .quarterly, .semiannual, .yearly]
    }
    
    // Calculate next renewal date from a given date
    func nextRenewalDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .semiannual:
            return calendar.date(byAdding: .month, value: 6, to: date) ?? date
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
        case .biweekly:
            return Decimal(26) / Decimal(12) // ~2.16
        case .monthly:
            return 1
        case .quarterly:
            return Decimal(1) / Decimal(3) // ~0.33
        case .semiannual:
            return Decimal(1) / Decimal(6) // ~0.166
        case .yearly:
            return Decimal(1) / Decimal(12) // ~0.083
        case .custom(let days):
            return Decimal(30) / Decimal(days)
        }
    }
}
