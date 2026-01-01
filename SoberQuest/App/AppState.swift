import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var currentAddiction: Addiction?
    @Published var isOnboardingCompleted: Bool = false
    @Published var hasProAccess: Bool = false
    
    private let dataManager = DataManager.shared
    private let superwallService = SuperwallService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadInitialState()
        observeSuperwallChanges()
    }
    
    private func loadInitialState() {
        isOnboardingCompleted = dataManager.isOnboardingCompleted()
        hasProAccess = superwallService.hasProAccess()
        
        if isOnboardingCompleted {
            currentAddiction = dataManager.getActiveAddiction()
        }
    }
    
    private func observeSuperwallChanges() {
        superwallService.$hasActiveSubscription
            .assign(to: \.hasProAccess, on: self)
            .store(in: &cancellables)
    }
    
    func setCurrentAddiction(_ addiction: Addiction) {
        currentAddiction = addiction
        dataManager.setActiveAddiction(addiction)
    }
    
    func refreshAddiction() {
        if let addiction = dataManager.getActiveAddiction() {
            currentAddiction = addiction
        }
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        dataManager.setOnboardingCompleted(true)
    }
}

