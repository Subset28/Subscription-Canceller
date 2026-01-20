//
//  NativeAdCard.swift
//  Unsub
//
//  A native ad view styled to match Unsub's premium aesthetic.
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

struct NativeAdCard: View {
    @ObservedObject var adManager: AdManager
    
    var body: some View {
        #if canImport(GoogleMobileAds)
        if let nativeAd = adManager.nativeAd as? GADNativeAd, adManager.isAdLoaded {
            NativeAdView(nativeAd: nativeAd)
                .frame(height: 120) // Fixed height often helps native ads
                .styleCard()
        }
        #else
        EmptyView() // No SDK = No Ad
        #endif
    }
}

#if canImport(GoogleMobileAds)
struct NativeAdView: UIViewRepresentable {
    let nativeAd: GADNativeAd
    
    func makeUIView(context: Context) -> GADNativeAdView {
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
        // If xib load fails (which it might if we don't have a xib), create programmatically.
        // For simplicity in SwiftUI, we'll build a custom UIView that lays out subviews matching our DesignSystem.
        return createCustomNativeAdView()
    }
    
    func updateUIView(_ nativeAdView: GADNativeAdView, context: Context) {
        nativeAdView.nativeAd = nativeAd
        
        // Populate assets
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        // Wire up interaction
        nativeAdView.callToActionView?.isUserInteractionEnabled = false // Let the whole view or button handle taps? 
        // Actually, for GADNativeAdView, the view handles clicks if assets are registered.
    }
    
    private func createCustomNativeAdView() -> GADNativeAdView {
        let adView = GADNativeAdView()
        
        // 1. Icon
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.layer.cornerRadius = 8
        iconView.clipsToBounds = true
        iconView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        adView.addSubview(iconView)
        adView.iconView = iconView
        
        // 2. Headline
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = .systemFont(ofSize: 17, weight: .semibold) // Matches .headline
        headlineLabel.textColor = UIColor(DesignSystem.Colors.textPrimary)
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        
        // 3. Ad Badge
        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "Ad"
        adBadge.font = .systemFont(ofSize: 11, weight: .bold)
        adBadge.textColor = .white
        adBadge.backgroundColor = UIColor(DesignSystem.Colors.warning)
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 4
        adBadge.clipsToBounds = true
        adView.addSubview(adBadge)
        // No asset view for badge, it's decorative
        
        // 4. Body
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular) // Matches .subheadline
        bodyLabel.textColor = UIColor(DesignSystem.Colors.textSecondary)
        bodyLabel.numberOfLines = 2
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        
        // 5. CTA Button
        let ctaButton = UIButton()
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.backgroundColor = UIColor(DesignSystem.Colors.textPrimary)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        ctaButton.layer.cornerRadius = 8
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        // Constraints
        NSLayoutConstraint.activate([
            // Icon: Top Left, 48x48
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            
            // Headline: Right of Icon
            headlineLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            headlineLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            headlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: adBadge.leadingAnchor, constant: -8),
            
            // Ad Badge: Top Right
            adBadge.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            adBadge.centerYAnchor.constraint(equalTo: headlineLabel.centerYAnchor),
            adBadge.widthAnchor.constraint(equalToConstant: 24),
            adBadge.heightAnchor.constraint(equalToConstant: 16),
            
            // Body: Below Headline
            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            
            // CTA: Bottom Right (or full width?) - Let's do Bottom Right styled
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            ctaButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -16),
            ctaButton.topAnchor.constraint(greaterThanOrEqualTo: bodyLabel.bottomAnchor, constant: 12)
        ])
        
        return adView
    }
}
#endif
