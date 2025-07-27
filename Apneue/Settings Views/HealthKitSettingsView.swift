//
//  HealthKitSettingsView.swift
//  Apneue
//
//  Created by Saad Anis on 02/07/2025.
//

import SwiftUI
import HealthKit

struct HealthKitSettingsView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var healthKitManager = HealthKitManager.shared
    @AppStorage("syncToHealthKit") var syncToHealthKit: Bool = false
    
    @AppStorage("syncHoldToHK") var syncHoldToHK: Bool = false
    @AppStorage("syncBreathingToHK") var syncBreathingToHK: Bool = false
    @AppStorage("syncTablesToHK") var syncTablesToHK: Bool = false
    
    @State var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    var body: some View {
            List {
                HStack {
                    Text("Authorization Status")
                    Spacer()
                    HStack {
                        switch authorizationStatus {
                        case .notDetermined:
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.secondary)
                        case .sharingDenied:
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        case .sharingAuthorized:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        @unknown default:
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        Group {
                            switch authorizationStatus {
                            case .notDetermined:
                                Text("Not Determined")
                            case .sharingDenied:
                                Text("Denied")
                            case .sharingAuthorized:
                                Text("Authorized")
                            @unknown default:
                                Text("Unknown")
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 6)
                    .padding(.leading, 8)
                    .padding(.trailing, 10)
                    .background {
                        switch authorizationStatus {
                        case .notDetermined:
                            Color.secondary.opacity(0.4)
                        case .sharingDenied:
                            Color.red.opacity(0.4)
                        case .sharingAuthorized:
                            Color.green.opacity(0.4)
                        @unknown default:
                            Color.gray.opacity(0.4)
                        }
                    }
                    .clipShape(.capsule)
                }
                Toggle(isOn: $syncToHealthKit) {
                    Text("Sync to Apple Health")
                    Text("Save sessions as mindful minutes to Apple Health.")
                }
                    .onChange(of: syncToHealthKit) { oldValue, newValue in
                        if newValue {
                            if HKHealthStore.isHealthDataAvailable() {
                                healthKitManager.requestAuthorization()
                            }
                        }
                    }
                    .onSubmit {
                        authorizationStatus = healthKitManager.getAuthorizationStatus()
                    }
                Section {
                    Toggle(isOn: $syncHoldToHK) {
                        Text("Sync Hold Sessions")
                        Text("Max hold sessions count towards mindful minutes.")
                    }
                    Toggle(isOn: $syncBreathingToHK) {
                        Text("Sync Breathing Sessions")
                        Text("Box and 4-7-8 breathing sessions count towards mindful minutes.")
                    }
                    Toggle(isOn: $syncTablesToHK) {
                        Text("Sync Table Sessions")
                        Text("CO₂, O₂, and custom table sessions count towards mindful minutes.")
                    }
                }
                .disabled(!syncToHealthKit)
            }
            .onAppear {
                authorizationStatus = healthKitManager.getAuthorizationStatus()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    authorizationStatus = healthKitManager.getAuthorizationStatus()
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.accentColor.opacity(0.08))
            .navigationTitle("Apple Health")
    }
}

#Preview {
    NavigationStack {
        HealthKitSettingsView()
    }
}
