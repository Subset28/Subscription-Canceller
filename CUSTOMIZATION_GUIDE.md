# SubTrack Lite Customization Guide

This guide covers common customizations you might want to make to SubTrack Lite.

## App Identity

### Change App Name

1. **Display Name** (what users see on home screen):
   - Open `Info.plist`
   - Change `CFBundleDisplayName` value to your desired name
   - Or: Xcode Project → Target → General → Display Name

2. **Code References**:
   - Search for "SubTrack Lite" in code
   - Update strings, comments, and documentation

### Change Bundle Identifier

1. Open Xcode project
2. Select target "SubTrackLite"
3. General tab → Bundle Identifier
4. Change to `com.yourcompany.yourappname`
5. Repeat for Widget target: `com.yourcompany.yourappname.widget`

### Update App Icon

1. **Create Icons**:
   - Design 1024x1024px icon (PNG, no transparency)
   - Use tool like [AppIconGenerator](https://appicon.co) for all sizes

2. **Add to Project**:
   - Open `Assets.xcassets/AppIcon.appiconset`
   - Drag 1024x1024 icon into "AppIcon" slot
   - Xcode generates all required sizes

3. **Icon Design Tips**:
   - Simple, recognizable shape
   - Works at small sizes (40x40)
   - No text (too small to read)
   - Consider iOS 18+ tinted style

### Update Accent Color

1. Open `Assets.xcassets/AccentColor.colorset`
2. Change color for light and dark modes
3. Or in code: `AppTheme.primaryAccent = Color.yourColor`

## Feature Customization

### Change Default Reminder Time

**File**: `SubTrackLite/Features/Settings/SettingsView.swift`

```swift
// Change default from 3 days to 7 days
@AppStorage("defaultReminderDays") private var defaultReminderDays = 7
```

Also update in `EditSubscriptionView.swift`:
```swift
@State private var reminderLeadTimeDays = 7
```

### Add More Billing Period Options

**File**: `SubTrackLite/Data/Models/Subscription.swift`

```swift
enum BillingPeriod: Codable, CaseIterable {
    case weekly
    case biweekly  // Add this
    case monthly
    case quarterly
    case semiannually  // Add this
    case yearly
    case custom(days: Int)
    
    // Add cases to displayName, daysInPeriod, nextRenewalDate, monthlyMultiplier
}
```

### Customize Notification Content

**File**: `SubTrackLite/Services/NotificationScheduler.swift`

```swift
let content = UNMutableNotificationContent()
content.title = "Payment Due Soon"  // Change this
content.body = "Your \(subscription.name) subscription renews in \(subscription.reminderLeadTimeDays) days for \(price)"  // Add price
content.sound = .default
```

### Change Cost Display Currency

**Default Behavior**: Uses device locale currency

**Force Specific Currency**:

**File**: `SubTrackLite/Services/CurrencyFormatter.swift`

```swift
// In init():
numberFormatter.currencyCode = "EUR"  // Force EUR instead of locale
```

**Multi-Currency Support**: Already supported per-subscription via `currencyCode` field.

### Modify Widget Appearance

**File**: `SubTrackLiteWidget/SubTrackLiteWidget.swift`

**Change Refresh Interval**:
```swift
// Change from 6 hours to 1 hour
let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)
```

**Change Number of Displayed Subscriptions**:
```swift
return subscriptions
    .filter { $0.isRenewingWithin(days: 30) }
    .prefix(5)  // Change from 3 to 5
```

## UI Customization

### Change Typography

**File**: `SubTrackLite/UI/Themes/AppTheme.swift`

```swift
struct Typography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)  // Use rounded font
    static let title = Font.title2.weight(.heavy)  // Make titles bolder
    // ... etc
}
```

### Modify Color Scheme

**File**: `SubTrackLite/UI/Themes/AppTheme.swift`

```swift
static let primaryAccent = Color.purple  // Change from blue
static let warningColor = Color.yellow   // Change from orange
static let dangerColor = Color.pink      // Change from red
```

### Customize Card Styling

**File**: `SubTrackLite/UI/Themes/AppTheme.swift`

```swift
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))  // Increase corner radius
            .shadow(color: AppTheme.shadowMedium, radius: 12, y: 4)  // Stronger shadow
    }
}
```

### Change List Style

**File**: `SubTrackLite/Features/List/SubscriptionListView.swift`

```swift
.listStyle(.insetGrouped)  // Change to .plain, .grouped, .sidebar, etc.
```

## Data & Export

### Modify CSV Export Format

**File**: `SubTrackLite/Services/CSVExportService.swift`

```swift
// Add more columns to CSV header and data rows
var csvString = "Name,Price,Currency,Billing Period,Next Renewal Date,Created Date,Notes\n"

// Add createdAt to export
let createdDate = dateFormatter.string(from: subscription.createdAt)
csvString += "\(name),\(price),\(currency),\(billingPeriod),\(renewalDate),\(createdDate),\(notes)\n"
```

### Add New Subscription Fields

1. **Update Model** (`Subscription.swift`):
```swift
@Model
final class Subscription {
    // ... existing fields
    var category: String?  // Add new field
    var icon: String?  // SF Symbol name
    
    init(..., category: String? = nil, icon: String? = nil) {
        // ... existing init
        self.category = category
        self.icon = icon
    }
}
```

2. **Update Edit View** (`EditSubscriptionView.swift`):
```swift
@State private var category = ""
@State private var icon = "app.fill"

// Add picker in form
Section {
    TextField("Category", text: $category)
    Picker("Icon", selection: $icon) {
        ForEach(availableIcons, id: \.self) { iconName in
            Label(iconName, systemImage: iconName)
        }
    }
}

// Save in saveSubscription()
existingSubscription.category = category
existingSubscription.icon = icon
```

3. **Update List View** to display new fields

## Onboarding

### Customize Onboarding Content

**File**: `SubTrackLite/Features/Onboarding/OnboardingView.swift`

**Change Text**:
```swift
Text("Your Custom Value Prop")
    .font(.largeTitle.bold())

Text("Your custom description text.")
    .font(.title3)
```

**Add More Pages**:
```swift
TabView(selection: $currentPage) {
    OnboardingPage1().tag(0)
    OnboardingPage2(...).tag(1)
    OnboardingPage3().tag(2)  // Add new page
}
```

**Skip Onboarding Entirely**:
```swift
// In ContentView.swift
var body: some View {
    SubscriptionListView()  // Always show main view
}
```

### Skip Notification Permission Request

**File**: `SubTrackLite/Features/Onboarding/OnboardingView.swift`

Remove or modify:
```swift
Button {
    // Don't request notifications
    hasCompletedOnboarding = true
} label: {
    Text("Get Started")
}
```

## Notifications

### Change Notification Sound

**File**: `SubTrackLite/Services/NotificationScheduler.swift`

```swift
content.sound = .defaultCritical  // Critical alert (overrides silent mode)
// Or custom sound:
content.sound = UNNotificationSound(named: UNNotificationSoundName("custom_sound.wav"))
```

**Add custom sound**:
1. Add `.wav` file to project
2. Reference in notification content

### Add Notification Actions

**File**: `SubTrackLite/Services/NotificationScheduler.swift`

```swift
// In init or requestAuthorization:
let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Details")
let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Remind Tomorrow")

let category = UNNotificationCategory(
    identifier: "SUBSCRIPTION_REMINDER",
    actions: [viewAction, snoozeAction],
    intentIdentifiers: []
)

notificationCenter.setNotificationCategories([category])
```

## In-App Purchases (Future)

### Enable StoreKit 2

**File**: `SubTrackLite/Services/Entitlements/EntitlementManager.swift`

```swift
// Change from always unlocked to checking purchases
@Published var hasPremiumAccess = false  // Start as false

init() {
    Task {
        await loadProducts()
        await checkPurchaseStatus()
    }
}

func loadProducts() async {
    do {
        products = try await Product.products(for: productIDs)
    } catch {
        print("Failed to load products: \(error)")
    }
}

func checkPurchaseStatus() async {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            if transaction.productID.contains("premium") {
                hasPremiumAccess = true
                return
            }
        }
    }
}
```

### Add Feature Gates

**Example - Limit Free Subscriptions**:

**File**: `SubTrackLite/Features/List/SubscriptionListView.swift`

```swift
Button {
    if !container.entitlementManager.hasPremiumAccess && allSubscriptions.count >= 3 {
        showUpgradePrompt = true
    } else {
        showingAddSubscription = true
    }
}
```

## Testing

### Add Test Data

Create a preview helper:

**File**: `SubTrackLite/Data/Models/Subscription+Preview.swift`

```swift
extension Subscription {
    static var preview: Subscription {
        Subscription(
            name: "Netflix",
            price: 15.99,
            billingPeriod: .monthly,
            nextRenewalDate: Date().addingTimeInterval(86400 * 5)
        )
    }
    
    static var previewData: [Subscription] {
        [
            Subscription(name: "Netflix", price: 15.99, billingPeriod: .monthly, nextRenewalDate: Date()),
            Subscription(name: "Spotify", price: 9.99, billingPeriod: .monthly, nextRenewalDate: Date()),
            Subscription(name: "iCloud", price: 2.99, billingPeriod: .monthly, nextRenewalDate: Date())
        ]
    }
}
```

Use in previews:
```swift
#Preview {
    SubscriptionListView()
        .modelContainer(previewContainer)
}
```

## Build Configuration

### Add Debug Features

**File**: Anywhere in code

```swift
#if DEBUG
Button("Add Test Data") {
    addTestSubscriptions()
}
#endif
```

### Environment Variables for Testing

**File**: `SubTrackLiteApp.swift`

```swift
init() {
    // Skip onboarding in UI tests
    if CommandLine.arguments.contains("UI-TESTING") {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
```

## Performance Optimization

### Optimize Large Lists

**File**: `SubTrackLite/Features/List/SubscriptionListView.swift`

```swift
// Use LazyVStack for very large lists
LazyVStack {
    ForEach(filteredSubscriptions) { subscription in
        SubscriptionRow(subscription: subscription)
    }
}
```

### Cache Computed Values

**File**: `SubTrackLite/Data/Models/Subscription.swift`

```swift
// If computing monthly cost is expensive:
private var _cachedMonthlyCost: Decimal?

var estimatedMonthlyCost: Decimal {
    if let cached = _cachedMonthlyCost {
        return cached
    }
    let computed = price * billingPeriod.monthlyMultiplier
    _cachedMonthlyCost = computed
    return computed
}
```

## Localization

### Add New Language

1. **Xcode**: Project → Info → Localizations → + Add Language
2. **Extract Strings**: Product → Export for Localization
3. **Translate** `.xliff` file
4. **Import**: Product → Import Localizations

### Localize Existing Strings

**File**: `Localizable.strings` (create if needed)

```
/* Subscription List */
"subscriptions_title" = "Subscriptions";
"add_subscription" = "Add Subscription";

/* Spanish */
"subscriptions_title" = "Suscripciones";
"add_subscription" = "Agregar Suscripción";
```

**Use in code**:
```swift
Text("subscriptions_title", bundle: .main, comment: "Main list title")
```

---

## Need More Help?

- Check inline code comments for specific implementation details
- Refer to `ARCHITECTURE.md` for design patterns
- Consult `README.md` for build instructions
- Review Apple's documentation for SwiftUI, SwiftData, WidgetKit

**Pro Tip**: Search the codebase for `// TODO:` comments - these mark areas intentionally left for future enhancement.
