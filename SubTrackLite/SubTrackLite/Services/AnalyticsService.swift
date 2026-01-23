//
//  AnalyticsService.swift
//  Unsub
//
//  Lightweight analytics wrapper.
//  Currently logs to console, but ready for Firebase/PostHog.
//

import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    enum Event: String {
        case paywallViewed = "paywall_viewed"
        case purchaseStarted = "purchase_started"
        case purchaseCompleted = "purchase_completed"
        case purchaseFailed = "purchase_failed"
        case subscriptionAdded = "subscription_added"
        case nativeAdImpression = "native_ad_impression"
    }
    
    func log(_ event: Event, params: [String: Any] = [:]) {
        // 1. Console Logging (Debug)
        print("📊 [Analytics] \(event.rawValue): \(params)")
        
        // 2. Future: Send to backend
        // Analytics.logEvent(event.rawValue, parameters: params)
    }
}
