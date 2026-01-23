//
//  AdManager.swift
//  Unsub
//
//  Manages Google AdMob Native Ads.
//

import SwiftUI
import Combine
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
    private var adLoader: AdLoader?
    private var rewardedAd: RewardedAd?
    #endif
    
    // Rewarded Ad Unit ID
    // In production: ca-app-pub-8981618797106308/8356112440
    #if DEBUG
    let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313" // Test ID
    #else
    let rewardedAdUnitID = "ca-app-pub-8981618797106308/8356112440" // Production ID
    #endif
    
    override init() {
        super.init()
        #if canImport(GoogleMobileAds)
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "08bda9bb8a98e5d6921659b958700cc6" ]
        #endif
        loadAd()
        loadRewardedAd()
    }
    
    func loadAd() {
        #if canImport(GoogleMobileAds)
        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        
        adLoader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: nil,
            adTypes: [.native],
            options: [multipleAdsOptions]
        )
        adLoader?.delegate = self
        adLoader?.load(Request())
        #endif
    }
    
    func loadRewardedAd() {
        #if canImport(GoogleMobileAds)
        let request = Request()
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("AdMob: Failed to load rewarded ad: \(error.localizedDescription)")
                    return
                }
                self?.rewardedAd = ad
                print("AdMob: Rewarded ad loaded.")
            }
        }
        #endif
    }
    
    func showRewardedAd(onReward: @escaping () -> Void) {
        #if canImport(GoogleMobileAds)
        guard let rewardedAd = rewardedAd else {
            print("AdMob: Rewarded ad not ready.")
            // Try to load one for next time
            loadRewardedAd()
            return
        }
        
        // Root VC needed to present
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        rewardedAd.present(from: root) {
            // User earned reward
            print("AdMob: User earned reward.")
            onReward()
            // Load next one
            self.loadRewardedAd()
        }
        #else
        // Mock success if SDK missing
        onReward()
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension AdManager: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        self.isAdLoaded = true
        print("AdMob: Native ad loaded successfully.")
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("AdMob: Failed to load ad: \(error.localizedDescription)")
        self.isAdLoaded = false
    }
}
#endif
