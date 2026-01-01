# SoberQuest iOS MVP

An iOS app for tracking sobriety with milestone badges and social sharing.

## Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. Create a new iOS App project
3. Name it "SoberQuest"
4. Choose SwiftUI as the interface
5. Set iOS deployment target to 16.0 or higher
6. Save the project in this directory

### 2. Add Source Files

Add all files from the `SoberQuest/` directory to your Xcode project:
- Models/
- Services/
- Views/
- App/

Make sure to:
- Add files to both "SoberQuest" and "SoberQuest Dev" targets
- Create proper folder groups in Xcode to match the directory structure

### 3. Create Second Target (SoberQuest Dev)

1. In Xcode, select the project in the navigator
2. Click the "+" button under TARGETS
3. Duplicate the "SoberQuest" target
4. Name it "SoberQuest Dev"
5. Configure separate bundle identifiers if needed

### 4. Add Superwall SDK

1. In Xcode, go to File → Add Package Dependencies
2. Add Superwall SDK: `https://github.com/superwall-me/Superwall-iOS`
3. Add it to both targets
4. Uncomment the import in `SuperwallService.swift`:
   ```swift
   import SuperwallKit
   ```
5. Update `SuperwallService.swift` with your actual API key

### 5. Add Badge Images

Create placeholder badge images in Assets.xcassets:

1. Open Assets.xcassets in Xcode
2. Create new Image Sets for each badge:
   - `badge_day1`
   - `badge_day3`
   - `badge_day7`
   - `badge_day14`
   - `badge_day30`
   - `badge_day60`
   - `badge_day90`

3. For MVP, you can use placeholder images (colored squares with numbers) or SF Symbols temporarily

### 6. Configure App Icons

1. Add app icons to Assets.xcassets
2. Configure launch screen (default SwiftUI launch screen is fine for MVP)

### 7. Build and Run

1. Select the "SoberQuest" scheme
2. Build and run on simulator or device
3. Test the onboarding flow

## Features

- **Onboarding**: Welcome → Addiction Setup → Badge Preview → Paywall
- **Home Screen**: Live sobriety timer, daily check-in, badge previews
- **Badge System**: 7 milestone badges (1, 3, 7, 14, 30, 60, 90 days)
- **Social Sharing**: Share cards optimized for Instagram Stories, TikTok, X
- **Multiple Addictions**: Track multiple addictions, switch between them
- **Local Storage**: All data stored locally using UserDefaults

## Superwall Configuration

1. Sign up for Superwall account
2. Create a paywall campaign
3. Set up entitlement: "pro"
4. Configure 7-day free trial
5. Update `SuperwallService.swift` with your API key
6. Implement Superwall callbacks for subscription status

## Testing Notes

- For MVP testing, `SuperwallService` simulates subscription status
- Set `hasActiveSubscription = true` in `SuperwallService.checkEntitlement()` to test without paywall
- Badge images are placeholders - replace with actual artwork
- All data is stored locally - uninstalling the app will delete data

## Project Structure

```
SoberQuest/
├── SoberQuest/
│   ├── App/
│   │   ├── SoberQuestApp.swift
│   │   └── AppState.swift
│   ├── Models/
│   │   ├── Addiction.swift
│   │   ├── BadgeDefinition.swift
│   │   └── UnlockedBadge.swift
│   ├── Services/
│   │   ├── DataManager.swift
│   │   ├── BadgeService.swift
│   │   └── SuperwallService.swift
│   └── Views/
│       ├── Onboarding/
│       ├── Home/
│       ├── Badges/
│       └── Settings/
```

## Next Steps

1. Replace placeholder badge images with actual artwork
2. Configure Superwall with real API keys
3. Test subscription flow end-to-end
4. Add app icons and launch screen
5. Test on physical device
6. Submit to TestFlight for beta testing

