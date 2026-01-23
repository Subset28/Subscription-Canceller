//
//  CalendarService.swift
//  SubTrackLite
//
//  Handles logic for syncing subscriptions to Apple Calendar (EventKit).
//

import Foundation
import EventKit
import Combine

@MainActor
class CalendarService: ObservableObject {
    private let store = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                let granted = try await store.requestFullAccessToEvents()
                self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return granted
            } else {
                let granted = try await store.requestAccess(to: .event)
                self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return granted
            }
        } catch {
            print("CalendarService: Access request failed: \(error)")
            return false
        }
    }
    
    func addEvent(for subscription: SubscriptionDTO) async throws -> String? {
        // Ensure access: Check strictly for permission or if we need to ask
        if #available(iOS 17.0, *) {
             if authorizationStatus != .fullAccess && authorizationStatus != .writeOnly {
                 let granted = await requestAccess()
                 if !granted { return nil }
             }
        } else {
             if authorizationStatus != .authorized {
                 let granted = await requestAccess()
                 if !granted { return nil }
             }
        }
        
        let event = EKEvent(eventStore: store)
        event.title = "\(subscription.name) Renewal"
        event.startDate = subscription.nextRenewalDate
        event.endDate = subscription.nextRenewalDate // All-day events usually span the day
        event.isAllDay = true
        event.notes = "Here is a link to cancel: \(subscription.cancelURL ?? "N/A")\n\nPrice: \(subscription.price)"
        event.calendar = store.defaultCalendarForNewEvents
        
        // Recurrence rule
        let recurrence = recurrenceRule(for: subscription.billingPeriod)
        event.addRecurrenceRule(recurrence)
        
        // Alarms: 1 day before
        event.addAlarm(EKAlarm(relativeOffset: -86400))
        
        do {
            try store.save(event, span: .futureEvents)
            return event.eventIdentifier
        } catch {
            print("CalendarService: Failed to save event: \(error)")
            throw error
        }
    }
    
    func removeEvent(identifier: String) async {
        // Simple check before removal
        if #available(iOS 17.0, *) {
            if authorizationStatus != .fullAccess && authorizationStatus != .writeOnly { return }
        } else {
            if authorizationStatus != .authorized { return }
        }
        
        if let event = store.event(withIdentifier: identifier) {
            do {
                try store.remove(event, span: .futureEvents)
            } catch {
                print("CalendarService: Failed to remove event: \(error)")
            }
        }
    }
    
    func addOrUpdateEvent(for subscription: SubscriptionDTO) async -> String? {
        if let existingID = subscription.calendarEventID {
            await removeEvent(identifier: existingID)
        }
        return try? await addEvent(for: subscription)
    }
    
    private func recurrenceRule(for period: BillingPeriod) -> EKRecurrenceRule {
        switch period {
        case .weekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case .biweekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case .monthly:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        case .quarterly:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 3, end: nil)
        case .semiannual:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 6, end: nil)
        case .yearly:
            return EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
        case .custom(let days):
             // Closest approximation for daily custom
            return EKRecurrenceRule(recurrenceWith: .daily, interval: days, end: nil)
        }
    }
}
