//
//  NotificationScheduler.swift
//  SubTrackLite
//
//  Manages local notification scheduling for subscription renewals
//

import Foundation
import UserNotifications
import Combine
import SwiftUI

@MainActor
class NotificationScheduler: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var scheduledNotifications: [UNNotificationRequest] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        Task {
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
                await checkAuthorizationStatus()
                print("Notification authorization: \(granted)")
            } catch {
                print("Failed to request notification authorization: \(error)")
            }
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Scheduling
    func scheduleNotification(for subscription: Subscription) {
        guard subscription.remindersEnabled else {
            cancelNotification(for: subscription)
            return
        }
        
        let calendar = Calendar.current
        let reminderDate = calendar.date(
            byAdding: .day,
            value: -subscription.reminderLeadTimeDays,
            to: subscription.nextRenewalDate
        ) ?? subscription.nextRenewalDate
        
        // Don't schedule if reminder date is in the past
        guard reminderDate > Date() else {
            print("Reminder date is in the past for \(subscription.name), skipping")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Subscription Renewal"
        content.body = "\(subscription.name) renews in \(subscription.reminderLeadTimeDays) day\(subscription.reminderLeadTimeDays == 1 ? "" : "s")"
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: subscription.notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        let subscriptionName = subscription.name // Capture value, not object
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(subscriptionName): \(error)")
            } else {
                print("Scheduled notification for \(subscriptionName) at \(reminderDate)")
            }
        }
    }
    
    func cancelNotification(for subscription: Subscription) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [subscription.notificationIdentifier])
        print("Cancelled notification for \(subscription.name)")
    }
    
    func updateNotification(for subscription: Subscription) {
        cancelNotification(for: subscription)
        scheduleNotification(for: subscription)
    }
    
    // MARK: - Debugging
    func refreshScheduledNotifications() {
        Task {
            let requests = await notificationCenter.pendingNotificationRequests()
            scheduledNotifications = requests
            await checkAuthorizationStatus()
        }
    }
    
    func getAllScheduledNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}
