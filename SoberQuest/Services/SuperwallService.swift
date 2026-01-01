import Foundation
import Combine
import SuperwallKit

class SuperwallService: ObservableObject {
    static let shared = SuperwallService()
    
    @Published var hasActiveSubscription: Bool = false
    
    private let apiKey: String = "pk_6ZItleafoqSsLP3gCE-xJ" // Replace with actual Superwall API key
    private let entitlement: String = "pro"
    
    private init() {
        configureSuperwall()
    }
    
    private func configureSuperwall() {
        // Configure Superwall SDK with the API key
        Superwall.configure(apiKey: apiKey)
        
        // Check initial entitlement status
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
    
    /// Presents the onboarding paywall using the configured placement
    /// - Parameter completion: Called when the paywall is dismissed with the result
    func presentOnboardingPaywall(completion: @escaping (PaywallResult) -> Void) {
        // Create a presentation handler to track paywall events
        let handler = PaywallPresentationHandler()
        
        handler.onPresent { info in
            print("Paywall presented: \(info)")
        }
        
        handler.onDismiss { info, result in
            DispatchQueue.main.async {
                // Handle the paywall dismissal result
                switch result {
                case .purchased:
                    self.hasActiveSubscription = true
                    completion(.purchased)
                case .declined:
                    completion(.declined)
                case .restored:
                    self.hasActiveSubscription = true
                    completion(.restored)
                }
            }
        }
        
        handler.onSkip { reason in
            print("Paywall skipped: \(reason)")
            // If paywall is skipped (e.g., user already subscribed), complete onboarding
            DispatchQueue.main.async {
                completion(.skipped)
            }
        }
        
        // Register the placement to trigger the Superwall paywall
        // Campaign: onboarding_paywall, Placement: onboarding_paywall_1
        Superwall.shared.register(placement: "onboarding_paywall_1", handler: handler)
    }
    
    /// Presents the paywall for general use (e.g., from settings or locked features)
    func presentPaywall() {
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { info, result in
            DispatchQueue.main.async {
                switch result {
                case .purchased, .restored:
                    self.hasActiveSubscription = true
                case .declined:
                    break
                }
            }
        }
        
        // Use the same placement for consistency
        Superwall.shared.register(placement: "onboarding_paywall_1", handler: handler)
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

