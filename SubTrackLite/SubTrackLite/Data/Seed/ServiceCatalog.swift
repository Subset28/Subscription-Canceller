//
//  ServiceCatalog.swift
//  SubTrackLite
//
//  Database of cancellation URLs for popular services.
//  Used to power the "Smart Concierge" auto-fill feature.
//

import Foundation

struct ServiceCatalog {
    static let cancelLinks: [String: String] = [
        // Streaming Video
        "netflix": "https://www.netflix.com/cancelplan",
        "hulu": "https://secure.hulu.com/account",
        "disney+": "https://www.disneyplus.com/account",
        "hbo max": "https://play.hbomax.com/page/urn:hbo:page:home",
        "max": "https://auth.max.com/subscription",
        "amazon prime": "https://www.amazon.com/gp/primecentral",
        "prime video": "https://www.amazon.com/gp/video/settings",
        "youtube premium": "https://www.youtube.com/paid_memberships",
        "peacock": "https://www.peacocktv.com/account/plans",
        "paramount+": "https://www.paramountplus.com/account/",
        "apple tv+": "https://support.apple.com/en-us/HT202039",
        
        // Music
        "spotify": "https://www.spotify.com/account/billing/",
        "apple music": "https://support.apple.com/en-us/HT202039",
        "tidal": "https://tidal.com/account",
        "pandora": "https://www.pandora.com/account/subscription",
        "amazon music": "https://www.amazon.com/music/settings",
        "soundcloud": "https://soundcloud.com/you/subscriptions",
        
        // Productivity & Software
        "adobe creative cloud": "https://account.adobe.com/plans",
        "microsoft 365": "https://account.microsoft.com/services",
        "dropbox": "https://www.dropbox.com/account/plan",
        "google one": "https://one.google.com/settings",
        "evernote": "https://www.evernote.com/Settings.action",
        "canva": "https://www.canva.com/settings/billing",
        "zoom": "https://zoom.us/billing",
        "slack": "https://my.slack.com/admin/billing/subscription",
        "github": "https://github.com/settings/billing",
        
        // News & Reading
        "new york times": "https://myaccount.nytimes.com/seg/cancellation",
        "wall street journal": "https://customercenter.wsj.com/customer-center",
        "washington post": "https://myaccount.washingtonpost.com/account/",
        "audible": "https://www.audible.com/account/overview",
        "medium": "https://medium.com/me/settings",
        "scribd": "https://www.scribd.com/account-settings",
        
        // Dating
        "tinder": "https://tinder.com/",
        "bumble": "https://bumble.com/help/subscription-cancellation",
        "hinge": "https://hinge.co/",
        
        // Fitness
        "peloton": "https://www.onepeloton.com/mymembership",
        "strava": "https://www.strava.com/settings/my_account",
        "fitbit premium": "https://www.fitbit.com/settings/subscription",
        "myfitnesspal": "https://www.myfitnesspal.com/account/premium",
        
        // Gaming
        "xbox game pass": "https://account.microsoft.com/services",
        "playstation plus": "https://library.playstation.com/edit-profile",
        "nintendo switch online": "https://ec.nintendo.com/my/membership",
        
        // Generic / Other
        "chegg": "https://www.chegg.com/my/account",
        "hellofresh": "https://www.hellofresh.com/account-settings/plan-settings",
        "blue apron": "https://www.blueapron.com/users/account",
        "dollar shave club": "https://www.dollarshaveclub.com/account"
    ]
    
    // Fuzzy search for a matching URL
    static func getCancelURL(for serviceName: String) -> String? {
        let normalizedName = serviceName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // 1. Exact match
        if let url = cancelLinks[normalizedName] {
            return url
        }
        
        // 2. Contains match (e.g. "Spotify Premium" -> "spotify")
        // We sort by length descending to match "Amazon Prime" before "Amazon" (if we had both)
        let sortedKeys = cancelLinks.keys.sorted { $0.count > $1.count }
        for key in sortedKeys {
            if normalizedName.contains(key) {
                return cancelLinks[key]
            }
        }
        
        return nil
    }
}
