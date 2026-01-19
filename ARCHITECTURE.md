# SubTrack Lite Architecture

## Overview

SubTrack Lite follows a clean MVVM (Model-View-ViewModel) architecture with a lightweight dependency injection container. The app is built with SwiftUI and SwiftData for a modern, declarative approach.

## Architecture Layers

### 1. App Layer
**Purpose**: Application entry point and global configuration

- `SubTrackLiteApp.swift`: Main app struct, scene configuration
- `DependencyContainer.swift`: Service initialization and dependency injection

**Design Decision**: Use `@StateObject` and `@EnvironmentObject` for service injection rather than singletons for better testability.

### 2. Data Layer
**Purpose**: Data models and persistence

- **Models**: SwiftData models with computed properties
  - `Subscription.swift`: Core subscription entity with renewal calculations
  - Uses `@Model` macro for automatic persistence
  - Computed properties for derived values (monthly cost, days until renewal)

**Why SwiftData**: 
- Declarative model definition with Swift macros
- Type-safe queries with `@Query`
- Automatic CloudKit sync support (future enhancement)
- Simpler than Core Data for this use case

**Fallback to Core Data**: Not needed for this app's requirements. SwiftData handles all persistence needs elegantly.

### 3. Service Layer
**Purpose**: Business logic and external framework interactions

Services are stateless or maintain minimal state:

- **NotificationScheduler**: Manages local notifications
  - Scheduling, updating, canceling notifications
  - Authorization status tracking
  - Deterministic notification IDs per subscription

- **CurrencyFormatter**: Currency formatting with locale support
  - Handles Decimal and Double types
  - Aggregate total calculations

- **CSVExportService**: Data export/import
  - CSV generation with proper escaping
  - Basic CSV parsing for import
  - Uses temporary file storage

- **EntitlementManager**: StoreKit 2 scaffolding
  - Feature-flagged for future IAP
  - All features unlocked in v1

**Design Decision**: Services are injected via DependencyContainer rather than being singletons, making them easy to mock in tests.

### 4. Feature Layer
**Purpose**: Screen-level views and navigation

Each feature is self-contained:

- **List**: Main subscription list with search/filter
  - Uses `@Query` for reactive data
  - Swipe actions for edit/delete
  - Summary card with totals

- **Detail**: Subscription details and upcoming renewals
  - Read-only view with edit/delete actions
  - Cancellation guidance (Apple vs. third-party)

- **Edit**: Add/edit subscription form
  - Validation logic
  - Auto-adjustment of past renewal dates
  - Notification scheduling on save

- **Settings**: App configuration and data management
  - Notification preferences
  - CSV export/import
  - Privacy information

- **Onboarding**: 2-screen onboarding flow
  - Value proposition
  - Privacy messaging + notification permission

**Design Pattern**: Each feature owns its view state. No shared ViewModels needed due to SwiftData's reactive `@Query`.

### 5. UI Layer
**Purpose**: Reusable components and theming

- **Components**: 
  - `EmptyStateView`: Reusable empty state component
  - Custom row views, cards

- **Themes**: 
  - `AppTheme`: Centralized design tokens
  - Custom button styles and modifiers

**Design Decision**: Keep components simple and composable. Avoid over-engineering component library.

### 6. Widget Extension
**Purpose**: WidgetKit integration

- **SubTrackLiteWidget**: Shows upcoming renewals
  - Uses same SwiftData container as main app
  - Timeline provider refreshes every 6 hours
  - Supports small and medium sizes

**Challenge**: Widgets run in separate process, need shared data access
**Solution**: Use same ModelContainer configuration for shared persistence

## Data Flow

### Adding a Subscription
```
User Input (EditView)
  → Validation
  → Create/Update Subscription model
  → Insert into ModelContext
  → Save ModelContext
  → Schedule notification (NotificationScheduler)
  → Dismiss view
  → @Query automatically updates list
```

### Displaying List
```
@Query fetches Subscriptions from SwiftData
  → Sort by nextRenewalDate
  → Apply filters (search text, time range)
  → Render SubscriptionRow for each item
  → Calculate totals with CurrencyFormatter
```

### Scheduling Notifications
```
Subscription saved/updated
  → Calculate reminder date (renewal - leadTimeDays)
  → Create UNNotificationRequest with deterministic ID
  → Add to UNUserNotificationCenter
  → (On update: cancel old notification first)
```

## Key Design Decisions

### 1. SwiftData over Core Data
- Simpler model definitions with macros
- Type-safe queries
- Better SwiftUI integration
- Adequate for app's needs

### 2. No ViewModels
- SwiftData's `@Query` provides reactive data
- Views handle their own state
- Business logic in services
- Keeps views simple and declarative

### 3. Lightweight DI Container
- Avoids global singletons
- Easy to mock services in tests
- Centralized initialization
- Passed via `@EnvironmentObject`

### 4. Decimal for Currency
- Precise arithmetic without floating-point errors
- NSDecimalNumber bridge for formatting
- Critical for financial calculations

### 5. Deterministic Notification IDs
- Each subscription has unique ID: `subscription-{UUID}`
- Easy to update/cancel specific notifications
- No need for separate notification tracking

### 6. Local-First, Offline-Only
- No network layer needed
- No authentication or user management
- All data in local SwiftData container
- CSV export/import for data portability

## Testing Strategy

### Unit Tests
- **Models**: Renewal calculations, cost computations
- **Services**: Currency formatting, CSV export/import
- **Business Logic**: Notification ID generation, date math

### UI Tests
- **Critical Path**: Add subscription → appears in list → reminder enabled
- **Empty States**: Verify empty state and navigation
- **Search/Filter**: Test filtering logic

### What's NOT Tested
- SwiftData persistence (framework responsibility)
- SwiftUI rendering (framework responsibility)
- Apple framework integrations (mocked in tests)

## Performance Considerations

### SwiftData Queries
- `@Query` is efficient and incremental
- Sorting at query level, not in-memory
- Predicates for filtering large datasets (if needed)

### Notification Scheduling
- Async operations on background queue
- Batch updates when possible
- Cancel before reschedule to avoid duplicates

### Widget Updates
- Timeline refreshes every 6 hours (not real-time)
- Fetch limited to 3 subscriptions
- Minimal battery impact

## Accessibility

- All UI elements have descriptive labels for VoiceOver
- Dynamic Type support throughout
- Sufficient color contrast ratios
- Semantic UI structure (headers, sections)

## Future Scalability

### If Adding Backend/Sync
1. Create Repository layer between Views and Services
2. Add network service to DependencyContainer
3. Implement conflict resolution for sync
4. Use SwiftData's CloudKit integration

### If Adding Complex Business Logic
1. Introduce ViewModels for complex screens
2. Move validation to separate validator objects
3. Add coordinator pattern for navigation

### If Adding More Features
1. Group features into modules/packages
2. Consider feature flags for A/B testing
3. Add analytics (respect privacy - local only)

## File Organization Principles

- Group by feature, not by file type
- Each feature owns its views and sub-components
- Shared components in UI layer
- Services are standalone and feature-agnostic
- Models are shared across all features

## Conventions

### Naming
- Views: `{Feature}View.swift` (e.g., `SubscriptionListView`)
- Models: Noun form (e.g., `Subscription`)
- Services: Action-oriented (e.g., `NotificationScheduler`)

### Comments
- Document non-obvious decisions
- Explain "why" not "what"
- Keep comments updated with code changes

### Swift Style
- SwiftLint for consistency (optional)
- Prefer `let` over `var`
- Use `guard` for early returns
- Async/await over completion handlers

## Dependencies

### First-Party Only
- SwiftUI
- SwiftData
- UserNotifications
- WidgetKit
- StoreKit (scaffolded)

**No third-party dependencies** for:
- Privacy reasons
- App size
- Maintenance burden
- Approval/security concerns

## Security & Privacy

- No data leaves device (except user-initiated CSV export)
- No analytics or crash reporting
- No third-party SDKs
- No network requests
- Notification content doesn't include sensitive info (just subscription name)

## Localization Strategy (Future)

Currently using `String(localized:)` for localization-readiness:
1. Extract strings to Localizable.strings
2. Add language-specific resources
3. Test with pseudo-localization
4. Support RTL languages

## Error Handling

- Graceful degradation (e.g., if notifications denied, still functional)
- User-facing error messages are descriptive
- Console logging for debugging (removed in release builds)
- No crashes on invalid data - validate inputs

---

This architecture prioritizes:
✅ **Simplicity** over complexity
✅ **Offline-first** experience
✅ **Privacy** by design
✅ **Testability** through DI
✅ **Maintainability** with clear separation
