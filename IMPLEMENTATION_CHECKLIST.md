# SoberQuest MVP Implementation Checklist

## ✅ Completed Code Files

All source files have been created and are ready to be added to your Xcode project:

### Models (3 files)
- ✅ `Models/Addiction.swift` - Core addiction model with sobriety tracking
- ✅ `Models/BadgeDefinition.swift` - Badge definitions with 7 milestones
- ✅ `Models/UnlockedBadge.swift` - Unlocked badge tracking model

### Services (3 files)
- ✅ `Services/DataManager.swift` - Local persistence using UserDefaults
- ✅ `Services/BadgeService.swift` - Badge milestone checking logic
- ✅ `Services/SuperwallService.swift` - Paywall integration (placeholder)

### App (2 files)
- ✅ `App/SoberQuestApp.swift` - Main app entry point
- ✅ `App/AppState.swift` - Global state management

### Views - Onboarding (4 files)
- ✅ `Views/Onboarding/WelcomeView.swift` - Welcome screen
- ✅ `Views/Onboarding/AddictionSetupView.swift` - Addiction selection and date picker
- ✅ `Views/Onboarding/BadgePreviewView.swift` - Badge preview
- ✅ `Views/Onboarding/OnboardingFlow.swift` - Complete onboarding flow with paywall

### Views - Home (2 files)
- ✅ `Views/Home/HomeView.swift` - Main screen with timer, check-in, badges
- ✅ `Views/Home/AddictionSelectorView.swift` - Switch between addictions

### Views - Badges (4 files)
- ✅ `Views/Badges/BadgeUnlockView.swift` - Badge unlock animation and sharing
- ✅ `Views/Badges/BadgeCollectionView.swift` - Grid of all badges
- ✅ `Views/Badges/ShareCardView.swift` - Social media share card generation
- ✅ `Views/Badges/BadgeImageView.swift` - Reusable badge image component with fallbacks

### Views - Settings (1 file)
- ✅ `Views/Settings/RelapseView.swift` - Reset progress functionality

## 📋 Xcode Project Setup Steps

### 1. Create Xcode Project
- [ ] Open Xcode → New Project → iOS App
- [ ] Name: "SoberQuest"
- [ ] Interface: SwiftUI
- [ ] Language: Swift
- [ ] iOS Deployment Target: 16.0+
- [ ] Save in `/Users/m.j/Projects/SoberQuest/`

### 2. Add Source Files
- [ ] Drag all files from `SoberQuest/` folder into Xcode project
- [ ] Ensure "Copy items if needed" is checked
- [ ] Add to both "SoberQuest" and "SoberQuest Dev" targets
- [ ] Create folder groups matching the directory structure

### 3. Create Second Target
- [ ] Select project in navigator
- [ ] Click "+" under TARGETS
- [ ] Duplicate "SoberQuest" target
- [ ] Rename to "SoberQuest Dev"
- [ ] Update bundle identifier (e.g., `com.yourcompany.soberquest.dev`)

### 4. Add Superwall SDK
- [ ] File → Add Package Dependencies
- [ ] URL: `https://github.com/superwall-me/Superwall-iOS`
- [ ] Add to both targets
- [ ] Uncomment `import SuperwallKit` in `SuperwallService.swift`
- [ ] Update API key in `SuperwallService.swift`

### 5. Add Badge Images
- [ ] Open `Assets.xcassets`
- [ ] Create Image Sets:
  - [ ] `badge_day1`
  - [ ] `badge_day3`
  - [ ] `badge_day7`
  - [ ] `badge_day14`
  - [ ] `badge_day30`
  - [ ] `badge_day60`
  - [ ] `badge_day90`
- [ ] Add placeholder images (colored squares with numbers) or actual artwork

### 6. Configure App
- [ ] Add app icons to Assets.xcassets
- [ ] Configure launch screen (default SwiftUI is fine)
- [ ] Set bundle identifier
- [ ] Configure signing & capabilities

### 7. Build & Test
- [ ] Build project (Cmd+B)
- [ ] Fix any import or compilation errors
- [ ] Run on simulator
- [ ] Test onboarding flow
- [ ] Test daily check-in
- [ ] Test badge unlock
- [ ] Test share functionality

## 🔧 Configuration Notes

### Superwall Setup
1. Sign up at superwall.com
2. Create paywall campaign
3. Set entitlement name: `"pro"`
4. Configure 7-day free trial
5. Get API key and update `SuperwallService.swift`

### Testing Without Paywall
Temporarily set in `SuperwallService.checkEntitlement()`:
```swift
hasActiveSubscription = true  // For testing
```

### Badge Images
- Placeholder images will show gradient squares with numbers
- Replace with actual fantasy-themed artwork
- Recommended size: 512x512px @2x, 1024x1024px @3x

## 🎯 Key Features Implemented

✅ Complete onboarding flow (Welcome → Setup → Preview → Paywall)
✅ Live sobriety timer (updates every second)
✅ Daily check-in with streak tracking
✅ Badge unlock system (7 milestones)
✅ Badge unlock animations
✅ Social sharing (Instagram Stories format)
✅ Badge collection view
✅ Multiple addictions support
✅ Addiction switching
✅ Progress reset (relapse handling)
✅ Local data persistence
✅ Paywall gating (Superwall integration)

## 🐛 Known Limitations (MVP)

- Superwall integration uses placeholder (needs real API key)
- Badge images are placeholders (need actual artwork)
- No cloud sync (local storage only)
- No notifications
- No analytics

## 📱 Next Steps After Setup

1. Replace placeholder badge images
2. Configure Superwall with real API keys
3. Test subscription flow end-to-end
4. Add app icons and polish UI
5. Test on physical device
6. Submit to TestFlight

