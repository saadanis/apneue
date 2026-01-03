//
//  IconsView.swift
//  Apneue
//
//  Created by Saad Anis on 25/12/2025.
//

import SwiftUI
import UIKit

struct IconsView: View {
    
    @AppStorage("colorThemeIndex") private var themeIndex: Int = 0
    
    @StateObject private var iconState = AppIconState()
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var store: StoreManager
    
    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 20),
        count: 3
    )
    
    private let iconNames: [String] = K.appIconNames
    
    @State var showingErrorAlert: Bool = false
    
    func isIconAvailable(_ index: Int) -> Bool {
        index == 0 || store.isProUnlocked
    }
    
    @ViewBuilder
    private func iconSection(_ title: String, startIndex: Int, endIndex: Int) -> some View {
        let lower = max(0, startIndex)
        let upper = min(iconNames.count, endIndex)
        
        if lower <= upper {
            Section(title) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(lower..<upper, id: \.self) { i in
                        Button {
                            let iconName = iconNames[i] == "ApneueIcon" ? nil : iconNames[i]
                            if UIApplication.shared.supportsAlternateIcons {
                                print("Supports alternate icons.")
                                UIApplication.shared.setAlternateIconName(iconName) { error in
                                    if let error {
                                        print("Failed to set icon: \(error)")
                                        showingErrorAlert = true
                                    } else {
                                        print("Success.")
                                    }
                                }
                            }
                        } label: {
                            VStack {
                                ZStack {
                                    Image(iconNames[i])
                                        .resizable()
                                        .scaledToFit()
                                        .environment(\.colorScheme, .dark)
                                        .rotationEffect(.degrees(14))
                                        .offset(x: 5)
                                        .padding(11)
                                        .shadow(radius: 4, x: 2, y: 3)
                                    Image(iconNames[i])
                                        .resizable()
                                        .scaledToFit()
                                        .environment(\.colorScheme, .light)
                                        .rotationEffect(.degrees(-6))
                                        .offset(x: -7, y: 4)
                                        .padding(10)
                                        .shadow(radius: 2, x: 3, y: 3)
                                }
                                Circle()
                                    .frame(width: 7, height: 7)
                                    .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                                    .opacity(UIApplication.shared.alternateIconName ?? "ApneueIcon" == iconNames[i] ? 1 : 0)
                            }
                        }
                        .buttonStyle(IconButtonStyle())
                        .disabled(!isIconAvailable(i))
                    }
                }
            }
        } else {
            // No-op if indices are invalid
            EmptyView()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThemedList(themeIndex: themeIndex) {
                iconSection("Simple", startIndex: 0, endIndex: 3)
                iconSection("A Little Less Simple", startIndex: 3, endIndex: 6)
                iconSection("Definitely Not Simple", startIndex: 6, endIndex: 9)
                iconSection("Umm...", startIndex: 9, endIndex: 10)
                Text("It must be pretty obvious by now that I'm not a designer, so I'll try to get someone to make better icons eventually.")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
            if !store.isProUnlocked {
                UnlockMessageView(title: "Unlock All Icons", message: "Support Apneue with a small one-time fee to unlock all these fun and pretty app icons.")
            }
        }
        .navigationTitle("Icons")
        .alert("Error", isPresented: $showingErrorAlert) {
            
        } message: {
            Text("Failed to update app icon. Please try again.\n\nAnd in case you've already tried again, it's probably due to a system bug and you'll have to restart your device. Sorry.")
        }
        
    }
}

struct IconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .compositingGroup()
            .opacity(isEnabled ? 1.0 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}

@MainActor
final class AppIconState: ObservableObject {
    @Published var currentIconName: String?
    
    init() {
        currentIconName = UIApplication.shared.alternateIconName
    }
    
    func refresh() {
        currentIconName = UIApplication.shared.alternateIconName
    }
}

#Preview {
    NavigationStack {
        IconsView()
            .environmentObject(StoreManager())
    }
    
}
