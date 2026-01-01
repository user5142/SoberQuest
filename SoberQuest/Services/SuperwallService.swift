import Foundation
import Combine
import SuperwallKit

class SuperwallService: ObservableObject {
    static let shared = SuperwallService()
    
    @Published var hasActiveSubscription: Bool = false
    @Published private(set) var isConfigured: Bool = false
    
    private let apiKey: String = "pk_6ZItleafoqSsLP3gCE-xJ" // Replace with actual Superwall API key
    private let entitlement: String = "pro"
    
    private init() {
        configureSuperwall()
    }
    
    private func configureSuperwall() {
        // Enable debug logging to see what's happening
        #if DEBUG
        let options = SuperwallOptions()
        options.logging.level = .debug
        Superwall.configure(apiKey: apiKey, options: options)
        #else
        Superwall.configure(apiKey: apiKey)
        #endif
        
        print("🔧 [Superwall] Configured with API key: \(apiKey.prefix(10))...")
        
        // Mark as configured
        isConfigured = true
        
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
        let placementName = "onboarding_paywall_1"
        
        print("🚀 [Superwall] Attempting to register placement: '\(placementName)'")
        print("🔧 [Superwall] SDK configured: \(isConfigured)")
        
        // Create a presentation handler to track paywall events
        let handler = PaywallPresentationHandler()
        
        handler.onPresent { info in
            print("✅ [Superwall] Paywall presented: \(info)")
        }
        
        handler.onDismiss { info, result in
            print("📤 [Superwall] Paywall dismissed with result: \(result)")
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
            print("⏭️ [Superwall] Paywall skipped - Reason: \(reason)")
            // Log the skip reason - the exact enum cases vary by SuperwallKit version
            // Common reasons: holdout, eventNotFound, noRuleMatch
            if case .eventNotFound = reason {
                print("   ↳ Event/placement '\(placementName)' not found in any campaign!")
                print("   ⚠️ Please verify:")
                print("      1. The API key is correct and for the right environment")
                print("      2. The placement '\(placementName)' exists in your Superwall dashboard")
                print("      3. The campaign is published and active")
            } else {
                print("   ↳ Skip reason: \(reason)")
            }
            
            DispatchQueue.main.async {
                completion(.skipped)
            }
        }
        
        handler.onError { error in
            print("❌ [Superwall] Error presenting paywall: \(error)")
        }
        
        // Register the placement to trigger the Superwall paywall
        // Campaign: onboarding_paywall, Placement: onboarding_paywall_1
        Superwall.shared.register(placement: placementName, handler: handler)
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

