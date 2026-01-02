import Foundation
import Combine
import SuperwallKit

class SuperwallService: ObservableObject {
    static let shared = SuperwallService()
    
    @Published var hasActiveSubscription: Bool = false
    @Published private(set) var isConfigured: Bool = false
    
    private let apiKey: String = "pk_6ZItleafoqSsLP3gCE-xJ" // Replace with actual Superwall API key
    private let entitlement: String = "pro"
    
    // Campaign placement identifiers
    // Onboarding campaign - shown to new users with trial offer
    private let onboardingPlacement = "onboarding_paywall"
    // Winback campaign - separate campaign for users who previously used a trial
    private let winbackPlacement = "winback_paywall"
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        configureSuperwall()
        observeSubscriptionStatus()
    }
    
    private func configureSuperwall() {
        Superwall.configure(apiKey: apiKey)
        isConfigured = true
        checkEntitlement()
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
    
    /// Refresh entitlement status - call this when app becomes active or after paywall dismissal
    func refreshEntitlement() async {
        // Force a restore to ensure we have the latest subscription status from StoreKit
        do {
            try await Superwall.shared.restorePurchases()
        } catch {
            // Restore failed - check current status anyway
            print("SuperwallService: Restore purchases failed: \(error)")
        }
        
        // After restore attempt, check the current status
        await MainActor.run {
            let status = Superwall.shared.subscriptionStatus
            switch status {
            case .active:
                hasActiveSubscription = true
            default:
                hasActiveSubscription = false
            }
        }
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
        
        handler.onSkip { [weak self] _ in
            // User was skipped from seeing the paywall (already has access, etc.)
            // Verify entitlement to be sure
            Task {
                await self?.refreshEntitlement()
                await MainActor.run {
                    completion(.skipped)
                }
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
        // For purchase/restore results, verify the subscription is actually active
        switch result {
        case .purchased, .restored:
            // Wait a moment for StoreKit to process, then verify
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            // Refresh to ensure we have the latest status
            await refreshEntitlement()
            
            await MainActor.run {
                if self.hasActiveSubscription {
                    // Purchase/restore was successful
                    if !hasUsedTrial {
                        DataManager.shared.setHasUsedTrial(true)
                    }
                    completion(result)
                } else {
                    // Purchase reported but subscription not active - treat as declined
                    // This can happen if the payment didn't complete
                    print("SuperwallService: Purchase/restore reported but subscription not active")
                    completion(.declined)
                }
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
        
        handler.onSkip { [weak self] _ in
            Task {
                await self?.refreshEntitlement()
            }
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

