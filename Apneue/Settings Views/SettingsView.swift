//
//  SettingsView.swift
//  Apneue
//
//  Created by Saad Anis on 05/06/2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("defaultTimerMode") var defaultTimerMode: String = "Max Hold"
        
    @Binding var themeIndex: Int
    
    let themes = K.colorThemes
    let themesCount = K.colorThemes.count
    
    @State private var transitionDirection: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 15) {
                        HStack(alignment: .center, spacing: 5) {
                            Text("Upgrade to Apneue")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("PRO")
                                .foregroundStyle(.white)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .glassEffect(.clear.tint(Color.accentColor), in: .capsule)
                        }
                        .padding(.top, 4)
                        Text("For a one-time purchase of only **$4.99**, get detailed statistics, unique themes, custom tables, and a lot more.")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button {
                            
                        } label: {
                            Text("Learn More")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .padding(.vertical, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive().tint(Color.accentColor))
                    }
//                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background {
                        WaterView<EmptyView, EmptyView>(waveColors: themes[themeIndex].waveColors, skyColors: themes[themeIndex].backgroundColors) {
                            EmptyView()
                        }
//                        .overlay {
//                            Color.black.opacity(0.2)
//                        }
                    }
                }
                Section {
                    HStack {
                        Button {
                            themeIndex = (themeIndex - 1 + themesCount) % themesCount
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .frame(width: 36, height: 36, alignment: .center)
                        .glassEffect(.regular.interactive(), in: Circle())
                        .buttonStyle(.borderless)
                        Spacer()
                        VStack {
                            Text("Theme")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(themes[themeIndex].name)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Button {
                            themeIndex = (themeIndex + 1) % themesCount
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .frame(width: 36, height: 36, alignment: .center)
                        .glassEffect(.regular.interactive(), in: Circle())
                        .buttonStyle(.borderless)
                    }
                }
                Section {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Sounds & Haptics", systemImage: "speaker.wave.2.fill")
                    }
                }
                Section {
                    Picker(selection: $defaultTimerMode) {
                        Text("Use Last Selection").tag("")
                        Text("Max Hold").tag("Max Hold")
                        Text("Box Breathing").tag("Box Breathing")
                        Text("CO₂ Table").tag("CO₂ Table")
                        Text("O₂ Table").tag("O₂ Table")
                    } label: {
                        Text("Default Timer Mode")
                    }
                    .pickerStyle(.menu)
                }
                Section {
                    NavigationLink {
                        HealthKitSettingsView()
                    } label: {
                        Label("Apple Health", systemImage: "heart.fill")
                    }
                    NavigationLink {
                        RemindersSettingsView()
                    } label: {
                        Label("Reminders", systemImage: "bell.fill")
                    }
                }
                Section("Instructions") {
                    NavigationLink {
                        UsageView()
                    } label: {
                        Label("Usage", systemImage: "info.circle.fill")
                    }
                    NavigationLink {
                        
                    } label: {
                        Label("Safety", systemImage: "exclamationmark.triangle.fill")
                    }
                }
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "app.translucent")
                    }
                }
            }
            .fontDesign(.rounded)
            .scrollContentBackground(.hidden)
            .background(Color.accentColor.opacity(0.08))
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    
    struct Preview: View {
        
        @State var isShowingSheet = true
        @State var colorThemeIndex = 0
        
        var body: some View {
//            VStack {
//                K.colorThemes[colorThemeIndex].backgroundColors[0]
//                    .ignoresSafeArea()
//            }
//            .sheet(isPresented: $isShowingSheet) {
                SettingsView(themeIndex: $colorThemeIndex)
                    .tint(K.colorThemes[colorThemeIndex].accentColor)
//            }
        }
    }
    
    return Preview()
}
