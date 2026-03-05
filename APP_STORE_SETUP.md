# How to Set Up Products in App Store Connect

Now that your app logic and `EntitlementManager` are fully ready to handle the in-app purchases, you must reflect those precise products in Apple's systems.

## 1. Prerequisites
- **Paid Applications Agreement**: You must have signed the Paid Applications Agreement in App Store Connect (under Agreements, Tax, and Banking). You will not be able to test or submit IAPs without doing this first.
- **Bundle ID**: Ensure the App ID is fully registered in your Apple Developer portal and linked to your App in App Store Connect.

## 2. Create the Subscriptions (Weekly, Monthly, Yearly)

Subscriptions are grouped together. This is so users can switch between Weekly, Monthly, and Yearly easily within the same "Premium" tier.

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/).
2. Select **My Apps** and choose your application.
3. In the left sidebar, under the **Monetization** section, select **Subscriptions**.
4. Create a new **Subscription Group** (e.g., "Premium Subscriptions"). The name is only for your reference.
5. Inside that group, click **Create** under Subscriptions to add a new auto-renewable subscription. Repeat this **three** times for your products:

### Weekly Plan
- **Reference Name**: Premium Weekly
- **Product ID**: `com.subtrack.lite.premium.weekly` (MUST exact match code)
- **Subscription Duration**: 1 Week
- Set your price (e.g., $1.99).
- Add the required **Localizations** (Display Name and Description for the App Store).

### Monthly Plan
- **Reference Name**: Premium Monthly
- **Product ID**: `com.subtrack.lite.premium.monthly` (MUST exact match code)
- **Subscription Duration**: 1 Month
- Set your price (e.g., $4.99).
- Add Localizations.

### Yearly Plan
- **Reference Name**: Premium Yearly
- **Product ID**: `com.subtrack.lite.premium.yearly` (MUST exact match code)
- **Subscription Duration**: 1 Year
- Set your price (e.g., $29.99).
- Add Localizations.

## 3. Create the Lifetime Purchase (Non-Consumable)

The Lifetime option is a one-time purchase, not a subscription, so it is configured in a different section.

1. Still in your app's sidebar in App Store Connect, go to **In-App Purchases** (under Monetization).
2. Click the **+** button.
3. Select **Non-Consumable** and click Create.
4. Fill out the details:
   - **Reference Name**: Lifetime Premium
   - **Product ID**: `com.subtrack.lite.premium.lifetime` (MUST exact match code)
   - Set your one-time price (e.g., $49.99).
   - Add the required Localizations.
5. Upload a screenshot for review (Apple requires a screenshot of the paywall interface where the user can buy this product before they will approve it).

## 4. Final Steps
- Once your App is built and you want to use genuine App Store Sandbox testing, you must go to the **Users and Access** section of App Store Connect and create a **Sandbox Tester Account**.
- Log into that Sandbox Account on your iOS test device (Settings > App Store > Sandbox Account).
- **CRITICAL**: Remember to disable the local StoreKit configuration file in your Xcode Scheme (`Edit Scheme... > Run > Options > StoreKit Configuration: None`) so the app points to Apple's sandbox servers containing these new products instead of the local file!
