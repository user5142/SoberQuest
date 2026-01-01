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
    
    /// Presents the onboarding paywall using the configured placement
    /// - Parameter completion: Called when the paywall is dismissed with the result
    func presentOnboardingPaywall(completion: @escaping (PaywallResult) -> Void) {
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { [weak self] _, result in
            DispatchQueue.main.async {
                switch result {
                case .purchased:
                    self?.hasActiveSubscription = true
                    completion(.purchased)
                case .declined:
                    completion(.declined)
                case .restored:
                    self?.hasActiveSubscription = true
                    completion(.restored)
                }
            }
        }
        
        handler.onSkip { _ in
            DispatchQueue.main.async {
                completion(.skipped)
            }
        }
        
        Superwall.shared.register(placement: "onboarding_paywall_1", handler: handler)
    }
    
    /// Presents the paywall for general use (e.g., from settings or locked features)
    func presentPaywall() {
        let handler = PaywallPresentationHandler()
        
        handler.onDismiss { [weak self] _, result in
            DispatchQueue.main.async {
                if case .purchased = result { self?.hasActiveSubscription = true }
                if case .restored = result { self?.hasActiveSubscription = true }
            }
        }
        
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

