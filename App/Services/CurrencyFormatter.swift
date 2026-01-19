//
//  CurrencyFormatter.swift
//  SubTrackLite
//
//  Handles currency formatting with locale support
//

import Foundation

class CurrencyFormatter {
    private let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
    }
    
    func format(_ amount: Decimal, currencyCode: String = Locale.current.currency?.identifier ?? "USD") -> String {
        numberFormatter.currencyCode = currencyCode
        let nsDecimalNumber = NSDecimalNumber(decimal: amount)
        return numberFormatter.string(from: nsDecimalNumber) ?? "\(amount)"
    }
    
    func format(_ amount: Double, currencyCode: String = Locale.current.currency?.identifier ?? "USD") -> String {
        let decimal = Decimal(amount)
        return format(decimal, currencyCode: currencyCode)
    }
    
    func formatTotal(_ subscriptions: [Subscription], period: TotalPeriod) -> String {
        guard !subscriptions.isEmpty else { return format(0) }
        
        let currencyCode = subscriptions.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
        let total: Decimal
        
        switch period {
        case .monthly:
            total = subscriptions.reduce(0) { $0 + $1.estimatedMonthlyCost }
        case .yearly:
            total = subscriptions.reduce(0) { $0 + $1.estimatedYearlyCost }
        }
        
        return format(total, currencyCode: currencyCode)
    }
}

enum TotalPeriod {
    case monthly
    case yearly
}
