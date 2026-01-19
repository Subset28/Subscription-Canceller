# SubTrack Lite - Complete File Tree

```
SubTrackLite/
├── .gitignore
├── .swiftlint.yml
├── README.md
├── ARCHITECTURE.md
├── CUSTOMIZATION_GUIDE.md
├── FILE_TREE.md
│
├── SubTrackLite.xcodeproj/
│   └── project.pbxproj
│
├── SubTrackLite/
│   ├── Info.plist
│   │
│   ├── App/
│   │   ├── SubTrackLiteApp.swift              # App entry point, scene configuration
│   │   └── DependencyContainer.swift          # Lightweight DI container for services
│   │
│   ├── Data/
│   │   └── Models/
│   │       └── Subscription.swift             # SwiftData model with billing logic
│   │
│   ├── Services/
│   │   ├── NotificationScheduler.swift        # Local notification management
│   │   ├── CurrencyFormatter.swift            # Currency formatting with locale support
│   │   ├── CSVExportService.swift             # CSV export/import functionality
│   │   └── Entitlements/
│   │       └── EntitlementManager.swift       # StoreKit 2 scaffolding (feature-flagged)
│   │
│   ├── Features/
│   │   ├── List/
│   │   │   └── SubscriptionListView.swift    # Main list with search, filter, totals
│   │   ├── Detail/
│   │   │   └── SubscriptionDetailView.swift  # Subscription details, upcoming renewals
│   │   ├── Edit/
│   │   │   └── EditSubscriptionView.swift    # Add/edit subscription form with validation
│   │   ├── Settings/
│   │   │   └── SettingsView.swift            # Settings, export, notifications, privacy
│   │   └── Onboarding/
│   │       └── OnboardingView.swift          # 2-screen onboarding flow
│   │
│   ├── UI/
│   │   ├── Components/
│   │   │   └── EmptyStateView.swift          # Reusable empty state component
│   │   └── Themes/
│   │       └── AppTheme.swift                # Design system tokens, modifiers, styles
│   │
│   └── Assets.xcassets/
│       ├── Contents.json
│       ├── AccentColor.colorset/
│       │   └── Contents.json                 # App accent color (light/dark)
│       └── AppIcon.appiconset/
│           └── Contents.json                 # App icon configuration
│
├── SubTrackLiteWidget/
│   └── SubTrackLiteWidget.swift              # WidgetKit extension (upcoming renewals)
│
├── SubTrackLiteTests/
│   └── SubscriptionTests.swift               # Unit tests (calculations, formatting)
│
└── SubTrackLiteUITests/
    └── SubTrackLiteUITests.swift             # UI tests (add subscription flow)
```

## File Count Summary

**Total Files**: 29

### By Category:
- **App Core**: 2 files (App entry, DI container)
- **Data Models**: 1 file (Subscription model)
- **Services**: 4 files (Notifications, formatting, export, entitlements)
- **Feature Views**: 5 files (List, Detail, Edit, Settings, Onboarding)
- **UI Components**: 2 files (Empty state, theme)
- **Widget**: 1 file (WidgetKit extension)
- **Tests**: 2 files (Unit tests, UI tests)
- **Assets**: 4 files (Asset catalog configs)
- **Configuration**: 6 files (README, docs, Xcode project, plist, gitignore, swiftlint)
- **Documentation**: 3 files (README, Architecture, Customization guide)

### Lines of Code (Estimated):
- **Swift Code**: ~2,500 lines
- **Tests**: ~500 lines
- **Documentation**: ~1,000 lines
- **Configuration**: ~200 lines

## Key Files Explained

### Core App Files
- `SubTrackLiteApp.swift`: SwiftUI app struct, lifecycle management
- `DependencyContainer.swift`: Initializes and provides all services via @EnvironmentObject

### Data Layer
- `Subscription.swift`: SwiftData model with @Model macro, includes billing calculations and renewal logic

### Services
- `NotificationScheduler.swift`: Manages UNUserNotificationCenter, schedules/cancels/updates notifications
- `CurrencyFormatter.swift`: Handles Decimal/Double currency formatting with locale support
- `CSVExportService.swift`: Export subscriptions to CSV, import CSV with basic parsing
- `EntitlementManager.swift`: StoreKit 2 scaffolding for future IAP (disabled in v1)

### Feature Views
- `SubscriptionListView.swift`: Main screen with @Query, search, filters, totals, swipe actions
- `SubscriptionDetailView.swift`: Shows full subscription details and upcoming renewals
- `EditSubscriptionView.swift`: Add/edit form with validation and notification scheduling
- `SettingsView.swift`: App settings, notification status, CSV export/import, privacy info
- `OnboardingView.swift`: 2-page onboarding with value prop and notification permission

### UI Components
- `EmptyStateView.swift`: Reusable empty state with icon, title, message, action button
- `AppTheme.swift`: Centralized design tokens (colors, spacing, corner radius, typography)

### Widget
- `SubTrackLiteWidget.swift`: WidgetKit timeline provider showing next 3 upcoming renewals

### Tests
- `SubscriptionTests.swift`: Unit tests for renewal calculations, cost computations, currency formatting
- `SubTrackLiteUITests.swift`: UI test for add subscription → appears in list → reminder enabled

### Assets
- `AccentColor.colorset`: App-wide accent color (blue) for light and dark modes
- `AppIcon.appiconset`: App icon configuration (placeholder for 1024x1024 icon)

### Documentation
- `README.md`: Complete project overview, architecture, build instructions
- `ARCHITECTURE.md`: Detailed architecture decisions, data flow, design patterns
- `CUSTOMIZATION_GUIDE.md`: Step-by-step customization instructions

## Missing Files (Intentionally)

These files are NOT included as they're standard Xcode-generated files:
- `ContentView.swift` - Replaced by feature views
- `Assets.xcassets/*.imageset` - No custom images in v1
- `Preview Content/` - Using inline previews
- `*.xib` or `*.storyboard` - Pure SwiftUI, no storyboards
- Third-party dependencies - None used

## How to Navigate

1. **Start with**: `README.md` for overview and build instructions
2. **Understand architecture**: `ARCHITECTURE.md` for design decisions
3. **Customize**: `CUSTOMIZATION_GUIDE.md` for common modifications
4. **Entry point**: `SubTrackLiteApp.swift` to see app initialization
5. **Data model**: `Subscription.swift` to understand core entity
6. **Main screen**: `SubscriptionListView.swift` for primary UI
7. **Services**: Check `Services/` folder for business logic

## Next Steps After Setup

1. Open `SubTrackLite.xcodeproj` in Xcode
2. Configure code signing (select your team)
3. Update bundle identifier if needed
4. Add app icon to `Assets.xcassets/AppIcon.appiconset/`
5. Customize accent color in `AccentColor.colorset`
6. Run on simulator or device
7. Run tests with Cmd+U
8. Customize as needed using `CUSTOMIZATION_GUIDE.md`
