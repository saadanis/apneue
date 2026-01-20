//
//  SettingsView.swift
//  Apneue
//
//  Created by Saad Anis on 05/06/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var store: StoreManager
    
    @AppStorage("defaultTimerMode") var defaultTimerMode: String = ""
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("skipInitialRest") var skipInitialRest: Bool = true
    
    @Query(sort: \Entry.timestamp, order: .reverse) var entries: [Entry]
    
    @AppStorage("colorThemeIndex") private var themeIndex: Int = 0
    
    let themes = K.colorThemes
    let themesCount = K.colorThemes.count
    
    
    let appURL = URL(string: "https://apps.apple.com/app/apneue/id6748847361")!
    
    @State private var goToSupporterView = false
    
    var body: some View {
        NavigationStack {
            ThemedList(themeIndex: themeIndex) {
                if !store.isProUnlocked {
                    Section("") {
                    NavigationLink {
                        SupporterView()
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Image(systemName: "heart")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.darker(by: -10),
                                            Color.blue
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Support Apneue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("For a one-time fee, unlock themes, app icons, and support development.")
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
//                    .listRowBackground(
//                        Color.blue.saturation(0.3).brightness(colorScheme == .dark ? -0.4 : 0.5)
//                    )
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                .blue.darker(by: -20),
                                .blue
                        ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .saturation(1.5)
                        .opacity(0.6)
                    )
                }
            }
                Section("Appearance") {
                    NavigationLink {
                        ThemesView()
                    } label: {
                        HStack {
                            ThemedLabel(themeIndex: themeIndex) {
                                Text("Theme")
                            } icon: {
                                Image(systemName: "paintpalette")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                            Text(K.colorThemes[themeIndex].name)
                                .foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink {
                        IconsView()
                    } label: {
                        HStack {
                            ThemedLabel("App Icon", systemImage: "app.grid", themeIndex: themeIndex)
                            Spacer()
                            Text((UIApplication.shared.alternateIconName ?? "Ocean").replacingOccurrences(of: "Icon", with: ""))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Preferences") {
                    Picker(selection: $defaultTimerMode) {
                        Text("Last Selection").tag("")
                        Divider()
                        Text("Max Hold").tag("Max Hold")
                        Text("Box Breathing").tag("Box Breathing")
                        Text("CO₂ Table").tag("CO₂ Table")
                        Text("O₂ Table").tag("O₂ Table")
                    } label: {
                        ThemedLabel("Default Mode", systemImage: "dot.circle", themeIndex: themeIndex)
                    }
                    .pickerStyle(.menu)
                    Toggle(isOn: $skipInitialRest) {
                        ThemedLabel(themeIndex: themeIndex) {
                            VStack(alignment: .leading) {
                                Text("Skip Initial Rest")
                                Text("Enabling this will skip the first rest period for CO₂ and O₂ timers.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .padding(.trailing, 5)
                            }
                        } icon: {
                            Image(systemName: "forward.end")
                                .rotationEffect(.degrees(skipInitialRest ? 0 : 180))
                                .animation(.bouncy(extraBounce: 0.2), value: skipInitialRest)
                        }
                    }
                    Toggle(isOn: $hapticsEnabled) {
                        ThemedLabel(themeIndex: themeIndex) {
                            Text("Haptic Feedback")
                        } icon: {
                            Image(systemName: "waveform")
                            //                                .fontWeight(.heavy)
                                .symbolVariant(hapticsEnabled ? .none : .slash)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }
                Section("Integrations") {
                    NavigationLink {
                        HealthKitSettingsView(themeIndex: themeIndex)
                    } label: {
                        ThemedLabel("Apple Health", systemImage: "heart", themeIndex: themeIndex)
                    }
                    NavigationLink {
                        RemindersSettingsView(themeIndex: themeIndex)
                    } label: {
                        ThemedLabel("Reminders", systemImage: "bell", themeIndex: themeIndex)
                    }
                }
                Section("Instructions") {
                    NavigationLink {
                        UsageView(themeIndex: themeIndex)
                    } label: {
                        ThemedLabel("Usage", systemImage: "info.circle", themeIndex: themeIndex)
                    }
                    NavigationLink {
                        SafetyView(themeIndex: themeIndex)
                    } label: {
                        ThemedLabel("Safety", systemImage: "exclamationmark.triangle", themeIndex: themeIndex)
                    }
                }
                Section("") {
                    ShareLink(item: appURL) {
                        ThemedLabel("Share Apneue", systemImage: "square.and.arrow.up", themeIndex: themeIndex)
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        requestReview()
                    }, label: {
                        ThemedLabel("Leave a Rating", systemImage: "star", themeIndex: themeIndex)
                    })
                    .buttonStyle(.plain)
                    if store.isProUnlocked {
                        NavigationLink {
                            SupporterView()
                        } label: {
                            ThemedLabel("Support Apneue", systemImage: "heart", themeIndex: themeIndex)
                        }
                    }
                    NavigationLink {
                        AboutView(themeIndex: themeIndex)
                    } label: {
                        ThemedLabel("About", systemImage: "app.translucent", themeIndex: themeIndex)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
            }
            //            .tint(K.colorThemes[themeIndex].accentColor)
        }
    }
}

struct ThemedLabel<Title: View, Icon: View>: View {
    
    let themeIndex: Int
    @ViewBuilder let title: () -> Title
    @ViewBuilder let icon: () -> Icon
    
    init(
        themeIndex: Int,
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.themeIndex = themeIndex
        self.title = title
        self.icon = icon
    }
    
    init(
        _ text: String,
        systemImage: String,
        themeIndex: Int
    ) where Title == Text, Icon == Image {
        self.themeIndex = themeIndex
        self.title = { Text(text) }
        self.icon = {
            Image(systemName: systemImage)
        }
    }
    
    var body: some View {
        Label {
            title()
        } icon: {
            icon()
                .font(.footnote)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(
                    LinearGradient(
                        colors: [
                            K.colorThemes[themeIndex].accentColor.darker(by: -10),
                            K.colorThemes[themeIndex].accentColor
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    
    struct Preview: View {
        
        @State var isShowingSheet = true
        @State var colorThemeIndex = 0
        @State var hapticsEnabled = true
        
        var body: some View {
            SettingsView()
                .tint(K.colorThemes[colorThemeIndex].accentColor)
                .environmentObject(StoreManager())
        }
    }
    
    return Preview()
}
