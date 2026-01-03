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
            colorThemeIndex = 0
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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(K.colorThemes[colorThemeIndex].accentColor)
                .environmentObject(store)
        }
        .modelContainer(sharedModelContainer)
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
    
    private var updatesTask: Task<Void, Never>?
    
    init() {
        updatesTask = listenForTransactionUpdates()
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    func loadProduct() async {
        do {
            let products = try await Product.products(for: ["com.saadanis.Apneue.Supporter"])
            product = products.first
        } catch {
            product = nil
        }
    }
    
    func buy() async -> Bool {
        guard let product else { return false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                return true
                
            case .userCancelled, .pending:
                return false
                
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }
    
    func restorePurchases() async {
        // StoreKit2 restore is typically: sync + entitlement refresh
        do { try await AppStore.sync() } catch { }
        await refreshEntitlements()
    }
    
    func refreshEntitlements() async {
        var unlocked = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == "com.saadanis.Apneue.Supporter" {
                    unlocked = true
                    break
                }
            } catch {
                // ignore unverified
            }
        }
        
        isProUnlocked = unlocked
    }
    
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                do {
                    let transaction = try await self.checkVerified(update)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    // ignore unverified
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe): return safe
        case .unverified: throw StoreKitError.notEntitled
        }
    }
}

enum StoreKitError: Error {
    case notEntitled
}

struct ColorTheme {
    let name: String
    let accentColor: Color
    let backgroundColors: [Color]
    let waveColors: [Color]
}
