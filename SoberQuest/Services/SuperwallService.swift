import Foundation
import Combine
import SuperwallKit
import StoreKit

class SuperwallService: ObservableObject {
    static let shared = SuperwallService()

    @Published var hasActiveSubscription: Bool = false
    @Published private(set) var isConfigured: Bool = false
    /// Indicates whether the SDK is fully ready for purchases (configuration complete + StoreKit warmed up)
    @Published private(set) var isReadyForPurchases: Bool = false

    private var apiKey: String {
        // Use Dev API key for dev bundle, otherwise use production key
        if Bundle.main.bundleIdentifier == "com.studionoo.SoberQuest.dev" {
            return "pk_-gSdqDJ42h7eUIL4iYaCj" // Dev Superwall API key
        } else {
            return "pk_6ZItleafoqSsLP3gCE-xJ" // Production Superwall API key
        }
    }
    private let entitlement: String = "pro"

    // Campaign placement identifiers
    // Onboarding campaign - shown to new users with trial offer
    private let onboardingPlacement = "onboarding_paywall"
    // Winback campaign - separate campaign for users who previously used a trial
    private let winbackPlacement = "winback_paywall"

    private var cancellables = Set<AnyCancellable>()
    private var transactionListenerTask: Task<Void, Never>?

    private init() {
        configureSuperwall()
        observeSubscriptionStatus()
        startTransactionListener()
    }

    private func configureSuperwall() {
        // Use completion handler to ensure SDK is fully ready before allowing purchases
        Superwall.configure(apiKey: apiKey) { [weak self] in
            guard let self = self else { return }

            // SDK is now fully configured
            DispatchQueue.main.async {
                self.isConfigured = true
                self.checkEntitlement()

                // Warm up StoreKit by triggering a products fetch
                // This ensures StoreKit is ready before presenting paywalls
                self.warmUpStoreKit()
            }
        }
    }

    /// Warms up StoreKit to ensure it's ready for purchases
    /// This is important on cold starts where StoreKit may not be initialized
    private func warmUpStoreKit() {
        Task {
            // First, check for any pending transactions from previous sessions
            await checkPendingTransactions()

            // Small delay to allow StoreKit to fully initialize on cold start
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            await MainActor.run {
                self.isReadyForPurchases = true
                print("SuperwallService: SDK ready for purchases")
            }
        }
    }

    /// Checks for and finishes any pending transactions from previous app sessions
    /// This is critical for cold starts where purchases may have completed while app was closed
    private func checkPendingTransactions() async {
        // Get all current entitlements/transactions
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Ensure transaction is finished
                if transaction.revocationDate == nil {
                    print("SuperwallService: Found active entitlement: \(transaction.productID)")
                    // Refresh entitlement status since we found an active subscription
                    await MainActor.run {
                        self.hasActiveSubscription = true
                    }
                }
            case .unverified(let transaction, _):
                print("SuperwallService: Unverified entitlement: \(transaction.productID)")
            }
        }

        // Also check for any unfinished transactions
        for await result in Transaction.unfinished {
            switch result {
            case .verified(let transaction):
                print("SuperwallService: Finishing unfinished transaction: \(transaction.productID)")
                await transaction.finish()
            case .unverified(let transaction, _):
                print("SuperwallService: Finishing unverified transaction: \(transaction.productID)")
                await transaction.finish()
            }
        }
    }

    /// Listens for StoreKit 2 transaction updates to handle pending/stuck transactions
    /// This is critical for cold starts where transactions may have completed while app was closed
    private func startTransactionListener() {
        transactionListenerTask = Task.detached { [weak self] in
            // Handle any pending transactions on app launch
            for await result in Transaction.updates {
                guard let self = self else { return }

                switch result {
                case .verified(let transaction):
                    // Transaction is valid - finish it and update subscription status
                    await transaction.finish()
                    print("SuperwallService: Finished pending transaction: \(transaction.productID)")

                    // Refresh entitlement status
                    await MainActor.run {
                        self.refreshEntitlement()
                    }

                case .unverified(let transaction, let error):
                    // Transaction failed verification - still finish it to clear the queue
                    print("SuperwallService: Unverified transaction \(transaction.productID): \(error)")
                    await transaction.finish()
                }
            }
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }
    
    /// Observe Superwall's subscription status changes via Combine publisher
    private func observeSubscriptionStatus() {
        Superwall.shared.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .active:
                    self.hasActiveSubscription = true
                case .inactive, .unknown:
                    self.hasActiveSubscription = false
                @unknown default:
                    self.hasActiveSubscription = false
                }
            }
            .store(in: &cancellables)
    }
    
    func checkEntitlement() {
        // Check Superwall subscription status
        Task { @MainActor in
            let status = Superwall.shared.subscriptionStatus
            switch status {
            case .active:
                hasActiveSubscription = true
            default:
                hasActiveSubscription = false
            }
        }
    }
    
    /// Refresh entitlement status by reading current subscription status
    /// Note: Does NOT call restorePurchases() as that shows alerts.
    /// The Combine observer on $subscriptionStatus handles reactive updates automatically.
    func refreshEntitlement() {
        // Simply read the current subscription status - no restore needed
        // Superwall's $subscriptionStatus publisher (observed in observeSubscriptionStatus)
        // automatically updates hasActiveSubscription when status changes
        let status = Superwall.shared.subscriptionStatus
        switch status {
        case .active:
            hasActiveSubscription = true
        default:
            hasActiveSubscription = false
        }
    }

    /// Ensures the SDK is ready for purchases after returning from background
    /// This is called when the app becomes active to handle cold starts and long background periods
    func ensureReadyForPurchases() {
        guard isConfigured else {
            // SDK not configured yet - configureSuperwall will handle this
            return
        }

        // If already ready, nothing to do
        guard !isReadyForPurchases else { return }

        // Re-warm StoreKit after returning from background
        warmUpStoreKit()
    }
    
    /// Presents the onboarding paywall using the appropriate placement based on trial history
    /// - Users who have previously used a trial see the win-back paywall
    /// - New users see the trial paywall
    /// - Parameter completion: Called when the paywall is dismissed with the result
    func presentOnboardingPaywall(completion: @escaping (AppPaywallResult) -> Void) {
        let hasUsedTrial = DataManager.shared.hasUsedTrial()
        let placement = hasUsedTrial ? winbackPlacement : onboardingPlacement
        
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { [weak self] _, superwallResult in
            guard let self = self else {
                DispatchQueue.main.async { completion(.declined) }
                return
            }
            
            // Map Superwall's result to our result type
            let mappedResult = self.mapSuperwallResult(superwallResult)
            
            // After paywall dismissal, verify the subscription status
            Task {
                await self.verifyAndCompletePaywallResult(
                    result: mappedResult,
                    hasUsedTrial: hasUsedTrial,
                    completion: completion
                )
            }
        }
        
        handler.onSkip { _ in
            // User was skipped from seeing the paywall (already has access, etc.)
            // The Combine observer handles status updates, just complete
            DispatchQueue.main.async {
                completion(.skipped)
            }
        }
        
        Superwall.shared.register(placement: placement, handler: handler)
    }
    
    /// Maps Superwall's PaywallResult to our AppPaywallResult
    private func mapSuperwallResult(_ superwallResult: PaywallResult) -> AppPaywallResult {
        switch superwallResult {
        case .purchased:
            return .purchased
        case .restored:
            return .restored
        case .declined:
            return .declined
        }
    }
    
    /// Verifies subscription status after paywall dismissal and completes with the appropriate result
    private func verifyAndCompletePaywallResult(
        result: AppPaywallResult,
        hasUsedTrial: Bool,
        completion: @escaping (AppPaywallResult) -> Void
    ) async {
        // For purchase/restore results, trust Superwall's result and wait for status to sync
        switch result {
        case .purchased, .restored:
            // Superwall only returns .purchased/.restored when StoreKit confirms success.
            // Wait for subscription status to sync with retry logic.
            let maxAttempts = 10
            let delayMs: UInt64 = 300_000_000 // 0.3 seconds between attempts

            for attempt in 1...maxAttempts {
                try? await Task.sleep(nanoseconds: delayMs)

                // Check current status
                let status = Superwall.shared.subscriptionStatus
                if case .active = status {
                    await MainActor.run {
                        self.hasActiveSubscription = true
                        if !hasUsedTrial {
                            DataManager.shared.setHasUsedTrial(true)
                            // Schedule trial ending reminder for new trial users (permission already requested during onboarding)
                            NotificationService.shared.scheduleTrialReminderIfPermitted()
                        } else {
                            // User is returning/subscribing after trial - cancel any pending reminder
                            NotificationService.shared.cancelTrialEndingReminder()
                        }
                        completion(result)
                    }
                    return
                }

                print("SuperwallService: Waiting for subscription status (attempt \(attempt)/\(maxAttempts))")
            }

            // If status still not active after retries, trust Superwall's result anyway
            // The Combine observer will update the UI when status eventually syncs
            await MainActor.run {
                print("SuperwallService: Subscription status not yet active, but trusting Superwall result")
                if !hasUsedTrial {
                    DataManager.shared.setHasUsedTrial(true)
                    // Schedule trial ending reminder for new trial users (permission already requested during onboarding)
                    NotificationService.shared.scheduleTrialReminderIfPermitted()
                } else {
                    // User is returning/subscribing after trial - cancel any pending reminder
                    NotificationService.shared.cancelTrialEndingReminder()
                }
                // Force update - Superwall confirmed the purchase succeeded
                self.hasActiveSubscription = true
                completion(result)
            }

        case .declined:
            await MainActor.run {
                completion(.declined)
            }

        case .skipped:
            await MainActor.run {
                completion(.skipped)
            }
        }
    }
    
    /// Presents the paywall for general use (e.g., from settings or locked features)
    /// Uses the same dual placement routing as onboarding
    func presentPaywall() {
        let hasUsedTrial = DataManager.shared.hasUsedTrial()
        let placement = hasUsedTrial ? winbackPlacement : onboardingPlacement
        
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { [weak self] _, superwallResult in
            guard let self = self else { return }
            
            let mappedResult = self.mapSuperwallResult(superwallResult)
            
            Task {
                await self.verifyAndCompletePaywallResult(
                    result: mappedResult,
                    hasUsedTrial: hasUsedTrial,
                    completion: { _ in }
                )
            }
        }
        
        handler.onSkip { _ in
            // The Combine observer handles status updates automatically
        }
        
        Superwall.shared.register(placement: placement, handler: handler)
    }
    
    var hasProAccess: Bool {
        return hasActiveSubscription
    }
    
    // Call this after successful subscription purchase
    func setSubscriptionActive(_ active: Bool) {
        hasActiveSubscription = active
    }
}

/// Result of paywall presentation (renamed to avoid conflict with SuperwallKit's PaywallResult)
enum AppPaywallResult {
    case purchased
    case restored
    case declined
    case skipped
}


