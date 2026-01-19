# SubTrack Lite

A minimal, offline-first iOS subscription tracker with local notification reminders. Built with SwiftUI and SwiftData.

## Overview

SubTrack Lite helps you track all your subscriptions in one place and reminds you before renewals. The app is completely private - no accounts, no backend, no analytics. All data is stored locally on your device.

## Features

- ✅ Track subscriptions with name, price, billing period, and renewal dates
- ✅ Local notification reminders before renewals (1, 3, 7, or 14 days)
- ✅ Calculate total monthly and yearly subscription costs
- ✅ Search and filter subscriptions
- ✅ View upcoming renewal dates
- ✅ WidgetKit widget showing next 3 renewals
- ✅ Export/import data as CSV
- ✅ Dark mode support
- ✅ VoiceOver and Dynamic Type accessibility
- ✅ 100% offline - no internet required

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Architecture

The app follows MVVM architecture with clean separation of concerns:

```
SubTrackLite/
├── App/
│   ├── SubTrackLiteApp.swift          # App entry point
│   └── DependencyContainer.swift      # Lightweight DI container
├── Features/
│   ├── List/
│   │   └── SubscriptionListView.swift # Main list with filtering & search
│   ├── Detail/
│   │   └── SubscriptionDetailView.swift # Detailed subscription view
│   ├── Edit/
│   │   └── EditSubscriptionView.swift # Add/edit subscription form
│   ├── Settings/
│   │   └── SettingsView.swift         # Settings & export
│   └── Onboarding/
│       └── OnboardingView.swift       # 2-screen onboarding
├── Data/
│   └── Models/
│       └── Subscription.swift         # SwiftData model
├── Services/
│   ├── NotificationScheduler.swift    # Local notification management
│   ├── CurrencyFormatter.swift        # Currency formatting
│   ├── CSVExportService.swift         # CSV export/import
│   └── Entitlements/
│       └── EntitlementManager.swift   # StoreKit 2 scaffolding
├── UI/
│   ├── Components/
│   │   └── EmptyStateView.swift      # Reusable empty state
│   └── Themes/
│       └── AppTheme.swift            # Design system constants
└── Tests/
    ├── SubTrackLiteTests/            # Unit tests
    └── SubTrackLiteUITests/          # UI tests
```

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Notifications**: UserNotifications framework
- **Widgets**: WidgetKit
- **IAP (scaffolded)**: StoreKit 2
- **Concurrency**: Swift Concurrency (async/await)
- **Testing**: XCTest

## Data Model

### Subscription
```swift
- id: UUID
- name: String
- price: Decimal
- currencyCode: String
- billingPeriod: BillingPeriod (weekly, monthly, quarterly, yearly, custom)
- nextRenewalDate: Date
- reminderLeadTimeDays: Int
- remindersEnabled: Bool
- isAppleSubscription: Bool
- cancelURL: String?
- notes: String?
- createdAt: Date
- updatedAt: Date
```

## Build Instructions

### 1. Clone or Extract Project
```bash
cd SubTrackLite
```

### 2. Open in Xcode
```bash
open SubTrackLite.xcodeproj
```

### 3. Configure Signing
- Select the project in Xcode
- Go to "Signing & Capabilities"
- Select your team
- Update Bundle Identifier if needed: `com.yourcompany.SubTrackLite`

### 4. Build and Run
- Select target device or simulator
- Press `Cmd + R` to build and run

### 5. Run Tests
- Press `Cmd + U` to run unit tests
- Use Test Navigator to run specific test suites

## Customization

### Change App Name
1. Update `CFBundleDisplayName` in `Info.plist`
2. Update app name in code and strings

### Change App Icon
1. Add icon assets to `Assets.xcassets/AppIcon.appiconset`
2. Use 1024x1024 for the App Store icon
3. Xcode will generate all required sizes

### Change Accent Color
1. Open `Assets.xcassets/AccentColor.colorset`
2. Set your desired color for light and dark modes

### Modify Default Reminder Time
Edit the default value in `SettingsView.swift`:
```swift
@AppStorage("defaultReminderDays") private var defaultReminderDays = 3
```

## Testing

### Unit Tests
Run unit tests to verify:
- Renewal date calculations (weekly, monthly, quarterly, yearly, custom)
- Monthly and yearly cost calculations
- Days until renewal logic
- Notification identifier generation
- Currency formatting

```bash
xcodebuild test -scheme SubTrackLite -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
Core flow test:
1. Add subscription with name, price, billing period
2. Verify subscription appears in list
3. Verify reminder is enabled by default

## Privacy & Data

- **No Account Required**: Start using immediately
- **No Data Collection**: Zero analytics or tracking
- **Local Storage**: All data stored in SwiftData container on device
- **No Backend**: Completely offline app
- **No Third-Party SDKs**: Only Apple frameworks

## Future Enhancements (Not in v1)

The app is intentionally minimal. Potential v2 features:
- [ ] StoreKit 2 IAP for premium features
- [ ] iCloud sync via CloudKit
- [ ] More billing period options
- [ ] Category tags for subscriptions
- [ ] Charts and spending insights
- [ ] Subscription sharing/splitting
- [ ] Currency conversion

## In-App Purchases (Scaffolded)

StoreKit 2 is scaffolded but disabled by default. All features are unlocked in v1.

To enable IAP later:
1. Configure products in App Store Connect
2. Update product IDs in `EntitlementManager.swift`
3. Implement purchase flow in `EntitlementManager`
4. Add feature gates in UI where needed

Current product IDs (placeholders):
- `com.subtrack.lite.premium.monthly`
- `com.subtrack.lite.premium.yearly`

## Widget

The app includes a small/medium widget showing the next 3 upcoming renewals:
- Auto-refreshes every 6 hours
- Shows subscription name, price, and days until renewal
- Color-coded by urgency (red ≤3 days, orange ≤7 days)
- Tapping opens app

## Notifications

Local notifications are scheduled using UNUserNotificationCenter:
- Each subscription gets a unique notification ID: `subscription-{UUID}`
- Notifications fire N days before renewal (configurable: 1, 3, 7, 14)
- Updating a subscription automatically updates its notification
- Deleting a subscription cancels its notification

## Accessibility

- Full VoiceOver support with descriptive labels
- Dynamic Type support for text scaling
- Sufficient color contrast in light and dark modes
- Semantic UI structure

## Known Limitations

1. **SwiftData iOS 17+ Only**: App requires iOS 17 minimum
2. **No iCloud Sync**: Data stays on device (use CSV export/import)
3. **Approximate Cost Calculations**: Monthly/quarterly costs use 30/91 day approximations
4. **Basic CSV Import**: Limited error handling for malformed CSVs
5. **Widget Refresh**: Every 6 hours (OS may limit refresh frequency)

## Troubleshooting

### Notifications Not Working
1. Check Settings > SubTrack Lite > Notifications
2. Ensure "Allow Notifications" is enabled
3. Use Debug Notifications view in Settings (DEBUG builds only)

### Data Not Persisting
1. Check iOS storage space
2. Verify app isn't in iCloud optimize storage mode
3. Try deleting and reinstalling app (data will be lost)

### Widget Not Updating
1. Widgets refresh on iOS schedule (not guaranteed every 6 hours)
2. Try removing and re-adding widget
3. Ensure app isn't backgrounded/killed

## License

This is a production-ready template. Customize as needed for your use case.

## Support

For issues or questions:
1. Check this README
2. Review inline code comments
3. Consult Apple documentation for SwiftUI, SwiftData, WidgetKit

---

**Built with ❤️ using SwiftUI and SwiftData**
