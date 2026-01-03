# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

Don't run build commands, user will perform this themself manually in Xcode.

Or use Xcode directly: open `SoberQuest.xcodeproj`, select the `SoberQuest` scheme, then Cmd+B to build, Cmd+R to run.

## Architecture Overview

**SwiftUI iOS app** (iOS 16.0+) for tracking sobriety with milestone badges and social sharing.

### Core Patterns

- **State Management**: `AppState.swift` is a singleton `ObservableObject` managing global state (current addiction, onboarding status, pro access). It observes `SuperwallService` via Combine.
- **Data Persistence**: `DataManager.swift` handles all UserDefaults persistence with JSON encoding for models.
- **Monetization**: `SuperwallService.swift` wraps SuperwallKit SDK with dual paywall strategy (trial for new users, win-back for returning users).

### Key Files

| File | Purpose |
|------|---------|
| `App/SoberQuestApp.swift` | App entry point, tab bar setup |
| `App/AppState.swift` | Global state singleton |
| `Services/DataManager.swift` | UserDefaults persistence layer |
| `Services/BadgeService.swift` | Badge unlock logic and milestone queries |
| `Services/SuperwallService.swift` | Superwall paywall integration |
| `Views/Home/HomeView.swift` | Main screen (545 lines - largest view) |
| `Views/Onboarding/OnboardingFlow.swift` | Onboarding orchestrator |

### Data Models

- **Addiction**: Tracked substance with `startDate`, computed `daysSober` and `timeComponents`
- **BadgeDefinition**: 8 milestone badges (day 0, 1, 3, 7, 14, 30, 60, 90)
- **UnlockedBadge**: Records which badges are unlocked per addiction

### Onboarding Flow

`OnboardingStep` enum in `WelcomeView.swift`: welcome → addictionSetup → dateSelection → motivationSetup → badgePreview → paywall

### Theme

Dark mode only. Colors and modifiers defined in `Theme/AppTheme.swift`. Use `.darkBackground()`, `.cardStyle()` modifiers.

## Testing Without Paywall

To bypass Superwall during development, temporarily modify `SuperwallService.checkEntitlement()` to set `hasActiveSubscription = true`.

## Dependencies

- **SuperwallKit**: `https://github.com/superwall-me/Superwall-iOS` (SPM)
  - Placements: `onboarding_paywall`, `winback_paywall`
