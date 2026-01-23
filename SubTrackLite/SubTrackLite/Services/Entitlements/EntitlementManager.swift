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
    @AppStorage("earnedExtraSlots") var earnedExtraSlots = 0
    @Published var hasPremiumAccess = false
    @Published var products: [Product] = []
    @Published var isLoadingProducts = false
    @Published var productLoadError: String?
    
    // Product IDs must match App Store Connect / Unsub.storekit
    // Product IDs must match App Store Connect / Unsub.storekit
    // User Pivot: Weekly removed. Monthly & Yearly only.
    private let productIDs = [
        "com.subtrack.lite.premium.monthly",
        "com.subtrack.lite.premium.yearly"
    ]
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        // Start listening for transaction updates (renewals, revocations)
        updates = newTransactionListenerTask()
        
        // Check current entitlement on launch
        Task {
            await updateEntitlementStatus()
            await loadProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - StoreKit Logic
    
    func loadProducts() async {
        guard !isLoadingProducts else { return }
        
        await MainActor.run {
            isLoadingProducts = true
            productLoadError = nil
        }
        
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            
            await MainActor.run {
                self.products = fetchedProducts
                // Sort by price (Weekly first)
                self.products.sort { $0.price < $1.price }
                self.isLoadingProducts = false
            }
        } catch {
            print("StoreKit: Failed to load products: \(error)")
            await MainActor.run {
                self.productLoadError = error.localizedDescription
                self.isLoadingProducts = false
            }
        }
    }
    
    func purchase(_ product: Product) async throws {
        AnalyticsService.shared.log(.purchaseStarted, params: ["product_id": product.id])
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is verified
            switch verification {
            case .verified(let transaction):
                // Transaction is valid
                await transaction.finish()
                await updateEntitlementStatus()
                AnalyticsService.shared.log(.purchaseCompleted, params: ["product_id": product.id])
                
            case .unverified(_, let error):
                // Transaction is suspect
                print("StoreKit: Unverified transaction: \(error)")
                AnalyticsService.shared.log(.purchaseFailed, params: ["reason": "unverified"])
            }
            
        case .userCancelled:
            AnalyticsService.shared.log(.purchaseFailed, params: ["reason": "cancelled"])
            break
            
        case .pending:
            AnalyticsService.shared.log(.purchaseFailed, params: ["reason": "pending"])
            break
            
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateEntitlementStatus()
    }
    
    private func updateEntitlementStatus() async {
        // Iterate through all current entitlements
        var hasActivePremium = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Check if this transaction is for one of our products and is not revoked
                if productIDs.contains(transaction.productID) {
                    hasActivePremium = true
                }
            }
        }
        
        // Update state
        withAnimation {
            self.hasPremiumAccess = hasActivePremium
        }
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                // When a transaction changes (renewed, revoked), update status
                await self.updateEntitlementStatus()
            }
        }
    }
    
    // MARK: - Feature Gates
    
    func canAddSubscription(currentCount: Int) -> Bool {
        if hasPremiumAccess { return true }
        // Free Limit = 3 (Aggressive Pivot) + Earned Slot Rewards
        return currentCount < (3 + earnedExtraSlots)
    }
    
    // Rewarded Ad integration
    func rewardUserWithSlot() {
        earnedExtraSlots += 1
        AnalyticsService.shared.log(.nativeAdImpression, params: ["type": "rewarded_slot_earned"])
    }
    
    // Notifications are Premium Only (Aggressive Pivot)
    var canUseNotifications: Bool { hasPremiumAccess }
    
    // Calendar View is Premium Only (Aggressive Pivot)
    var isCalendarUnlocked: Bool { hasPremiumAccess }
    
    // GATED: The "Pro" stuff
    var canSyncToCalendar: Bool { hasPremiumAccess } // Adding to Apple Calendar is PREMIUM
    
    // GATED: The "Pro" stuff
    var isCategoryUnlocked: Bool { true } // Ungated: Core Organization feature
    var canExportData: Bool { hasPremiumAccess } // Data sovereignty
    var isChartsUnlocked: Bool { hasPremiumAccess } // Spending DNA
    var isConciergeUnlocked: Bool { hasPremiumAccess } // Legal Email Generator
    var isSmartRemindersUnlocked: Bool { hasPremiumAccess } // > 3 day reminders
}

