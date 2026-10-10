//
//  ApneueApp.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData
import HealthKit
import StoreKit
import Foundation

@main
struct ApneueApp: App {
    
    @AppStorage("colorThemeIndex") private var colorThemeIndex: Int = 0
    @AppStorage("lastHandledVersion") private var lastHandledVersion: String = ""
    
    @StateObject private var store = StoreManager()
    
    init() {
        UserDefaults.standard.register(defaults: [
            
            "defaultTimerMode": "Max Hold",
            "lastUsedMode": "Max Hold",
            
            "boxBreathingDuration": 4,
            "boxBreathingNumberOfRounds": 10,
            
            "co2NumberOfRounds": 8,
            "co2HoldPercentage": 0.5,
            "co2RestStartingDuration": 120,
            "co2RestEndingDuration": 15,
            
            "o2NumberOfRounds": 8,
            "o2RestDuration": 75,
            "o2HoldStartingPercentage": 0.5,
            "o2HoldEndingPercentage": 1.0,
            
            "onboardingComplete": false,
            "colorThemeIndex": 0,
            
            "syncToHealthKit": false,
            "syncHoldToHK": false,
            "syncBreathingToHK": true,
            "syncTablesToHK": true,
            
            "skipInitialRest": true,
        ])
        
        let currentVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        if lastHandledVersion != currentVersion {
            lastHandledVersion = currentVersion
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Entry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private var effectiveThemeIndex: Int {
        let stored = min(max(colorThemeIndex, 0), K.colorThemes.count - 1)
        return store.isProUnlocked ? stored : 0
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.themeIndex, effectiveThemeIndex)
                .tint(K.colorThemes[effectiveThemeIndex].accentColor)
                .environmentObject(store)
                .task {
                    await store.refreshEntitlements()
                }
                .onChange(of: store.isProUnlocked) { wasUnlocked, isUnlocked in
                    if wasUnlocked && !isUnlocked {
                        resetAlternateAppIcon()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// Only called on an observed revocation. A merely *failed* entitlement check must never
    /// clear a supporter's chosen icon (issue 2).
    private func resetAlternateAppIcon() {
        guard UIApplication.shared.supportsAlternateIcons,
              UIApplication.shared.alternateIconName != nil else { return }
        UIApplication.shared.setAlternateIconName(nil)
    }
}

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    var healthStore = HKHealthStore()
    
    let mindfulnessType = HKCategoryType(.mindfulSession)
    
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: [mindfulnessType], read: nil) { success, error in
            if success {
                print("Save the sample here or call method that saves sample.")
            } else {
                print("Error:", error ?? "Unknown error.")
                print("Failed to request, not denied authorization, you can retry.")
            }
        }
    }
    
    func writeSample(from start: Date, to end: Date) {
        let sample = HKCategorySample(type: HKCategoryType(.mindfulSession), value: 0, start: start, end: end)
        healthStore.requestAuthorization(toShare: [mindfulnessType], read: nil) { success, error in
            if success {
                self.healthStore.save(sample) { success, error in
                    if success {
                        print("Saved successfully.")
                    } else {
                        print(error ?? "Unknown error.")
                    }
                }
            } else {
                print("Error:", error ?? "Unknown error.")
                print("Failed to request, not denied authorization, you can retry.")
            }
        }
    }
    
    func getAuthorizationStatus() -> HKAuthorizationStatus {
        return self.healthStore.authorizationStatus(for: mindfulnessType)
    }
}

@MainActor
final class StoreManager: ObservableObject {
    
    @Published private(set) var product: Product?
    @Published private(set) var isProUnlocked: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    @Published private(set) var isRestoring: Bool = false
    @Published private(set) var isLoadingProduct: Bool = false
    
    init() {
        listenForTransactionUpdates()
        Task { await loadProduct() }
    }
    
    func loadProduct() async {
        // The launch load and the paywall's retry can overlap; the second would otherwise
        // clear the spinner while the first is still in flight.
        guard !isLoadingProduct else { return }
        
        isLoadingProduct = true
        defer {
            isLoadingProduct = false
        }
        
        do {
            let products = try await Product.products(for: [K.supporterProductID])
            product = products.first
        } catch {
            product = nil
        }
    }
    
    func buy() async -> PurchaseOutcome {
        guard let product else { return .unavailable }
        
        isPurchasing = true
        defer {
            isPurchasing = false
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try await verified(verification)
                await transaction.finish()
                await refreshEntitlements()
                return .success
                
            case .userCancelled:
                return .cancelled
                
            case .pending:
                return .pending
                
            @unknown default:
                return .cancelled
            }
        } catch {
            return .failed(error)
        }
    }
    
    func restorePurchases() async -> RestoreOutcome {
        isRestoring = true
        defer {
            isRestoring = false
        }
        
        do {
            try await AppStore.sync()
        } catch StoreKitError.userCancelled {
            return .cancelled
        } catch {
            return .failed(error)
        }
        
        await refreshEntitlements()
        return isProUnlocked ? .restored : .noPurchasesFound
    }
    
    func refreshEntitlements() async {
        var unlocked = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await verified(result)
                if transaction.productID == K.supporterProductID {
                    unlocked = true
                    break
                }
            } catch {
                // ignore unverified
            }
        }
        
        isProUnlocked = unlocked
    }
    
    private func listenForTransactionUpdates() {
        Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try await self.verified(update)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    // Unverified: already finished by `verified(_:)`, nothing to deliver.
                }
            }
        }
    }
    
    /// Unverified transactions are finished before rethrowing: StoreKit otherwise re-queues them on
    /// every launch, leaving a paid user with no entitlement and no error, forever.
    private func verified(_ result: VerificationResult<StoreKit.Transaction>) async throws -> StoreKit.Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified(let transaction, let error):
            await transaction.finish()
            throw error
        }
    }
}

enum PurchaseOutcome {
    case success
    case cancelled
    case pending
    case unavailable
    case failed(Error)
}

enum RestoreOutcome {
    case restored
    case cancelled
    case noPurchasesFound
    case failed(Error)
}

struct ColorTheme {
    let name: String
    let accentColor: Color
    let backgroundColorsLight: [Color]
    let backgroundColorsDark: [Color]
    let waveColors: [Color]
    
    func backgroundColors(for scheme: ColorScheme) -> [Color] {
        scheme == .dark ? backgroundColorsDark : backgroundColorsLight
    }
}
