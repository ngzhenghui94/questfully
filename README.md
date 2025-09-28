# Questfully

## StoreKit & Apple Developer Setup

While your Apple Developer Program membership is pending, here’s the checklist to get subscriptions and Sign in with Apple fully working once access is granted.

### 1. Apple Developer Account
- **Enroll & Approval**: Wait for the approval email. Once active, sign in at <https://developer.apple.com/account/>.
- **Two-Factor Authentication**: Make sure the Apple ID you’ll use supports 2FA; StoreKit and App Store Connect require it.

### 2. Certificates, Identifiers & Profiles
1. **App ID**
   - Navigate to *Certificates, Identifiers & Profiles → Identifiers*.
   - Create a new App ID (type: App) matching the bundle identifier in `questfully.xcodeproj`.
   - Enable capabilities:
     - Sign in with Apple
     - In-App Purchase
     - Push Notifications (optional if you plan to add reminders later)
2. **Services ID (optional but recommended)**
   - Needed if you will support Sign in with Apple on the web. Create one and link to the App ID.
3. **Keys**
   - Generate a Sign in with Apple private key (Keys → “+” → Sign in with Apple). Download the `.p8` and note the Key ID.
4. **Provisioning Profile**
   - Create a development and/or distribution profile for the App ID. Download and double-click to install locally.

### 3. App Store Connect Configuration
1. **Create the App Record**
   - Go to <https://appstoreconnect.apple.com/> → *My Apps* → “+”. Provide the bundle ID, SKU, and app name.
2. **In-App Purchases (IAP)**
   - Under the app → *Features* → *In-App Purchases*, create a subscription group.
   - Add two auto-renewable subscriptions:
     - Product ID `questfully.premium.monthly`
     - Product ID `questfully.premium.annual`
   - Fill in localized display names, descriptions, pricing, and review screenshots.
   - Submit each product for review (they can remain in “Ready to Submit” until the first binary is uploaded).
3. **App Privacy & Compliance**
   - Complete the privacy questionnaire and export compliance in App Store Connect.

### 4. Xcode Project Updates (once account is active)
1. **Sign in to Xcode** (`Settings… → Accounts`) with the approved Apple ID.
2. **Download Profiles**: Xcode will auto-manage signing if you select the new team under *Signing & Capabilities* for each target.
3. **Enable Capabilities**: In the project editor ensure `questfully` target has:
   - Sign in with Apple
   - In-App Purchase
4. **StoreKit Testing Configuration**
   - Create a StoreKit configuration file (`File → New → StoreKit Configuration File`).
   - Add the same product IDs (`questfully.premium.monthly` & `questfully.premium.annual`).
   - Select the configuration under *Scheme → Edit Scheme → Run → Options → StoreKit Configuration* to test locally without hitting the App Store.

### 5. Backend / Verification (optional but recommended)
- If you plan to sync entitlements across platforms, set up a backend to verify receipts. Apple provides the App Store Server API & App Store Server Notifications for this purpose.
- Store and use the Sign in with Apple private key to validate identity tokens server-side.

### 6. Testing Checklist
- [ ] Run on device/simulator with StoreKit configuration file.
- [ ] Purchase monthly and annual products; verify `SubscriptionManager` reflects premium status.
- [ ] Trigger restore purchases via Profile tab; ensure entitlements reapply.
- [ ] Sign in with Apple flow returns valid credentials and populates the UI.
- [ ] Verify daily quota resets after midnight and is bypassed when premium is active.

### 7. Release Preparation
- Once StoreKit and Sign in with Apple are confirmed in development:
  - Build an archive (`Product → Archive`) and upload to App Store Connect.
  - Attach the build to your in-app purchases (they must be in “Ready to Submit”).
  - Submit the app for review.

Keep this checklist handy; you can check off items as your Apple Developer access goes live. Let me know if you want automation scripts or templates for any of the steps above once your account is approved.