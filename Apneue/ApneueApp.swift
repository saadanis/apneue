//
//  ApneueApp.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData
import HealthKit

@main
struct ApneueApp: App {
    
    init() {
        UserDefaults.standard.register(defaults: [
            
            "defaultTimerMode": "Max Hold",
            "lastUsedMode": "Max Hold",
            
            "maxHoldDuration": 0,
            "maxHoldDate": Date(),
            
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

struct ColorPalette {
    let name: String
    let colors: [Color]
}

struct ColorTheme {
    let name: String
    let accentColor: Color
    let backgroundColors: [Color]
    let waveColors: [Color]
}
