//
//  EntitlementManager.swift
//  SubTrackLite
//
//  StoreKit 2 scaffolding for future IAP support (feature-flagged)
//  V1: All features unlocked, no hard gates
//

import Foundation
import StoreKit

@MainActor
class EntitlementManager: ObservableObject {
    @Published var hasPremiumAccess = true // V1: Always true, no paywall
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
        // In production: do {
        //     products = try await Product.products(for: productIDs)
        // } catch { ... }
    }
    
    func purchase(_ product: Product) async throws {
        // Stub for StoreKit 2 purchase flow
        // In production: implement purchase logic
    }
    
    func restorePurchases() async {
        // Stub for restore purchases
    }
    
    // Feature gates (all unlocked in v1)
    var canAddUnlimitedSubscriptions: Bool { hasPremiumAccess }
    var canExportData: Bool { hasPremiumAccess }
    var canUseWidgets: Bool { hasPremiumAccess }
}
