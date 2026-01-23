//
//  SubscriptionDTO.swift
//  SubTrackLite
//
//  Thread-safe value type for passing subscription data to background services.
//

import Foundation

struct SubscriptionDTO: Sendable {
    let id: UUID
    let name: String
    let price: Decimal
    let billingPeriod: BillingPeriod
    let nextRenewalDate: Date
    let reminderLeadTimeDays: Int
    let remindersEnabled: Bool
    let cancelURL: String?
    let categoryRaw: String
    let currencyCode: String
    
    // Calendar specific
    let calendarEventID: String?
    
    // Initializer from Domain Model
    init(from subscription: Subscription) {
        self.id = subscription.id
        self.name = subscription.name
        self.price = subscription.price
        self.billingPeriod = subscription.billingPeriod
        self.nextRenewalDate = subscription.nextRenewalDate
        self.reminderLeadTimeDays = subscription.reminderLeadTimeDays
        self.remindersEnabled = subscription.remindersEnabled
        self.cancelURL = subscription.cancelURL
        self.categoryRaw = subscription.categoryRaw
        self.currencyCode = subscription.currencyCode
        self.calendarEventID = subscription.calendarEventID
    }
    
    var notificationIdentifier: String {
        "subscription-\(id.uuidString)"
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: price as NSNumber) ?? "\(price)"
    }
}
