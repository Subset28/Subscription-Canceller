//
//  BillingPeriod.swift
//  SubTrackLite
//
//  Enum representing subscription billing cycles
//

import Foundation

public enum BillingPeriod: Codable, Sendable, Hashable {
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
    // Manual Codable implementation to resolve Swift 6 / SwiftData isolation issues
    enum CodingKeys: String, CodingKey {
        case type, days
    }
}

extension BillingPeriod {
    nonisolated public init(from decoder: Decoder) throws {
        do {
            // Attempt to decode as new keyed container (Swift 6 compliant format)
            if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                let type = try container.decodeIfPresent(String.self, forKey: .type)
                switch type {
                case "weekly": self = .weekly
                case "biweekly": self = .biweekly
                case "monthly": self = .monthly
                case "quarterly": self = .quarterly
                case "semiannual": self = .semiannual
                case "yearly": self = .yearly
                case "custom":
                    let days = try container.decode(Int.self, forKey: .days)
                    self = .custom(days: days)
                default:
                    self = .monthly
                }
                return
            }
            
            // Fallback: Try decoding as single value (Legacy format)
            let container = try decoder.singleValueContainer()
            if let stringVal = try? container.decode(String.self) {
                 print("BillingPeriod: Recovering from legacy format (String): \(stringVal)")
                 self = .monthly
            } else {
                 print("BillingPeriod: Unknown legacy format. Defaulting to .monthly")
                 self = .monthly
            }
        } catch {
            print("BillingPeriod: Decoding failed (Corruption?): \(error). Defaulting to .monthly")
            self = .monthly
        }
    }
    
    nonisolated public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .weekly: try container.encode("weekly", forKey: .type)
        case .biweekly: try container.encode("biweekly", forKey: .type)
        case .monthly: try container.encode("monthly", forKey: .type)
        case .quarterly: try container.encode("quarterly", forKey: .type)
        case .semiannual: try container.encode("semiannual", forKey: .type)
        case .yearly: try container.encode("yearly", forKey: .type)
        case .custom(let days):
            try container.encode("custom", forKey: .type)
            try container.encode(days, forKey: .days)
        }
    }
}
