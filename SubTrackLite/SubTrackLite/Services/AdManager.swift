//
//  AdManager.swift
//  Unsub
//
//  Manages Google AdMob Native Ads.
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@MainActor
class AdManager: NSObject, ObservableObject {
    @Published var nativeAd: Any? // Store as Any to avoid build errors without SDK
    @Published var isAdLoaded = false
    
    // Test Unit ID for Native Advanced
    // In production, use: ca-app-pub-8981618797106308/2449373160
    #if DEBUG
    let adUnitID = "ca-app-pub-3940256099942544/3986624511" // Test ID
    #else
    let adUnitID = "ca-app-pub-8981618797106308/2449373160" // Production ID
    #endif
    
    #if canImport(GoogleMobileAds)
    private var adLoader: GADAdLoader?
    #endif
    
    override init() {
        super.init()
        loadAd()
    }
    
    func loadAd() {
        #if canImport(GoogleMobileAds)
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        
        adLoader = GADAdLoader(
            adUnitID: adUnitID,
            rootViewController: nil,
            adTypes: [.native],
            options: [multipleAdsOptions]
        )
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension AdManager: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        self.isAdLoaded = true
        print("AdMob: Native ad loaded successfully.")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("AdMob: Failed to load ad: \(error.localizedDescription)")
        self.isAdLoaded = false
    }
}
#endif
