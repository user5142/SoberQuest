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
    
    private init() {
        configureSuperwall()
    }
    
    private func configureSuperwall() {
        Superwall.configure(apiKey: apiKey)
        isConfigured = true
        checkEntitlement()
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
    
    /// Presents the onboarding paywall using the appropriate placement based on trial history
    /// - Users who have previously used a trial see the win-back paywall
    /// - New users see the trial paywall
    /// - Parameter completion: Called when the paywall is dismissed with the result
    func presentOnboardingPaywall(completion: @escaping (PaywallResult) -> Void) {
        let hasUsedTrial = DataManager.shared.hasUsedTrial()
        let placement = hasUsedTrial ? winbackPlacement : onboardingPlacement
        
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { [weak self] _, result in
            DispatchQueue.main.async {
                switch result {
                case .purchased:
                    self?.hasActiveSubscription = true
                    // Mark trial as used when purchasing via trial paywall
                    if !hasUsedTrial {
                        DataManager.shared.setHasUsedTrial(true)
                    }
                    completion(.purchased)
                case .declined:
                    completion(.declined)
                case .restored:
                    self?.hasActiveSubscription = true
                    // Mark trial as used on restore as well (user had prior subscription)
                    if !hasUsedTrial {
                        DataManager.shared.setHasUsedTrial(true)
                    }
                    completion(.restored)
                }
            }
        }
        
        handler.onSkip { _ in
            DispatchQueue.main.async {
                completion(.skipped)
            }
        }
        
        Superwall.shared.register(placement: placement, handler: handler)
    }
    
    /// Presents the paywall for general use (e.g., from settings or locked features)
    /// Uses the same dual placement routing as onboarding
    func presentPaywall() {
        let hasUsedTrial = DataManager.shared.hasUsedTrial()
        let placement = hasUsedTrial ? winbackPlacement : onboardingPlacement
        
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { [weak self] _, result in
            DispatchQueue.main.async {
                switch result {
                case .purchased:
                    self?.hasActiveSubscription = true
                    if !hasUsedTrial {
                        DataManager.shared.setHasUsedTrial(true)
                    }
                case .restored:
                    self?.hasActiveSubscription = true
                    if !hasUsedTrial {
                        DataManager.shared.setHasUsedTrial(true)
                    }
                case .declined:
                    break
                }
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

/// Result of paywall presentation
enum PaywallResult {
    case purchased
    case restored
    case declined
    case skipped
}

