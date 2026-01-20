//
//  EntitlementManager.swift
//  SubTrackLite
//
//  StoreKit 2 scaffolding for future IAP support (feature-flagged)
//  V1: All features unlocked, no hard gates
//

import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class EntitlementManager: ObservableObject {
    @Published var hasPremiumAccess = false // Default to FALSE to test free tier
    @Published var products: [Product] = []
    
    private let productIDs = [
        "com.subtrack.lite.premium.monthly",
        "com.subtrack.lite.premium.yearly"
    ]
    
    init() {
        // V1: No-op, ready for StoreKit 2 integration later
    }
    
    func loadProducts() async {
        // Stub for StoreKit 2 product loading
    }
    
    func purchase(_ productID: String) async {
        // Mock purchase
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        hasPremiumAccess = true
    }
    
    func restorePurchases() async {
        // Mock restore
        hasPremiumAccess = true
    }
    
    // Feature gates
    func canAddSubscription(currentCount: Int) -> Bool {
        if hasPremiumAccess { return true }
        return currentCount < 3 // Strict limit of 3
    }
    
    var canUseNotifications: Bool { hasPremiumAccess }
    var canExportData: Bool { hasPremiumAccess }
}
