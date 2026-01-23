//
//  SpotlightService.swift
//  SubTrackLite
//
//  Indexes subscriptions for iOS Spotlight Search.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import UIKit

class SpotlightService {
    static let shared = SpotlightService()
    
    private init() {}
    
    func index(_ subscription: SubscriptionDTO) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        attributeSet.title = subscription.name
        attributeSet.contentDescription = "Subscription - \(subscription.formattedPrice)"
        attributeSet.keywords = ["subscription", "bill", "payment", subscription.name, subscription.categoryRaw]
        
        // Add an icon if possible (using system images is tricky for spotlight, usually need local file)
        // For now, we'll skip the thumbnailImage or use a generic symbol logic if we had assets.
        
        let item = CSSearchableItem(
            uniqueIdentifier: subscription.id.uuidString,
            domainIdentifier: "com.subtrack.lite.subscriptions",
            attributeSet: attributeSet
        )
        
        // Expiration date (next renewal)
        item.expirationDate = subscription.nextRenewalDate.addingTimeInterval(60 * 60 * 24 * 365) // Keep valid for a year? Or just let it persist
        
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Spotlight: Indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    func deindex(_ subscription: SubscriptionDTO) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [subscription.id.uuidString]) { error in
            if let error = error {
                print("Spotlight: Deindexing error: \(error.localizedDescription)")
            }
        }
    }
    
    // Legacy overload for deletion if id is available
    func deindex(id: UUID) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id.uuidString]) { error in
            if let error = error {
                print("Spotlight: Deindexing error: \(error.localizedDescription)")
            }
        }
    }
    
    func deindexAll() {
        CSSearchableIndex.default().deleteAllSearchableItems { error in
             if let error = error {
                print("Spotlight: Delete All error: \(error.localizedDescription)")
            }
        }
    }
}
