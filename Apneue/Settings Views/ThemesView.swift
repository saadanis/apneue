//
//  ThemesView.swift
//  Apneue
//
//  Created by Saad Anis on 18/12/2025.
//

import SwiftUI

struct SimplerThemeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var themeIndex: Int = 0
    var height: CGFloat = 180
    
    var waveColors: [Color] {
        if K.colorThemes[themeIndex].waveColors.count >= 4 {
            return K.colorThemes[themeIndex].waveColors
        }
        return K.interpolateColors(
            colorA: K.colorThemes[themeIndex].waveColors[0],
            colorB: K.colorThemes[themeIndex].waveColors[1],
            steps: 2
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundStyle(
                    LinearGradient(
                        colors: K.colorThemes[themeIndex].backgroundColors(for: colorScheme),
                        startPoint: UnitPoint(x: 0.5, y: -1),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                )
            ForEach(0..<4, id: \.self) { i in
                let waveColor = colorScheme == .light ? waveColors[i] : waveColors[i].darker(by: 30)
                Rectangle()
                    .foregroundStyle(waveColor)
                    .saturation(colorScheme == .light ? 1 : 1.5)
                    .shadow(color: waveColor.darker(by: -50), radius: 0, x: 0, y: -1)
                    .frame(height: CGFloat(
                        height - height/2.3 - CGFloat(9*i)
                    ))
                    .offset(y: 2)
                
            }
        }
        .frame(height: height)
    }
}

struct ThemesView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("colorThemeIndex") private var themeIndex: Int = 0
    @EnvironmentObject var store: StoreManager
    
    let themes = K.colorThemes
    let themesCount = K.colorThemes.count
    
    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )
    
    @ViewBuilder
    private func themeSection(_ title: String, startIndex: Int, endIndex: Int) -> some View {
        let lower = max(0, startIndex)
        let upper = min(themes.count, endIndex)
        
        if lower <= upper {
            Section(title) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(lower..<upper, id: \.self) { i in
                        Button {
                            themeIndex = i
                        } label: {
                            ZStack(alignment: .bottom) {
                                if themeIndex == i {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.clear)
                                        .overlay {
                                            WaterView(
                                                waveColors: themes[i].waveColors,
                                                skyColors: themes[i].backgroundColors(for: colorScheme),
                                                isAnimated: themeIndex == i
                                            ) {
                                                EmptyView()
                                            } secondaryContent: { _ in
                                                EmptyView()
                                            }
                                            .scaleEffect(0.5)
                                            .frame(width: 450)
                                            
                                        }
                                } else {
                                    SimplerThemeView(themeIndex: i)
                                }
                                Text(themes[i].name)
                                    .foregroundStyle(themes[i].accentColor)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(.thickMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(10)
                            }
                            .overlay {
                                if themeIndex == i {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            themes[i].accentColor,
                                            lineWidth: 6
                                        )
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                            .frame(height: 180)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isThemeAvailable(i))
                        .opacity(isThemeAvailable(i) ? 1 : 0.9)
                        .saturation(isThemeAvailable(i) ? 1 : 0.5)

                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    func isThemeAvailable(_ index: Int) -> Bool {
        index == 0 || store.isProUnlocked
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThemedList(themeIndex: themeIndex) {
                themeSection("Simple", startIndex: 0, endIndex: 6)
                themeSection("Colorful", startIndex: 6, endIndex: 12)
                themeSection("Varied", startIndex: 12, endIndex: 18)
            }
            if !store.isProUnlocked {
                UnlockMessageView(title: "Unlock All Themes", message: "Support Apneue with a small one-time fee to unlock all these fun and pretty themes.")
            }
        }
        .navigationTitle("Theme")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", systemImage: "checkmark", role: .close) {
                    dismiss()
                }
            }
        }
    }
}

struct UnlockMessageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            NavigationLink {
                SupporterView()
            } label: {
                Text("Become a Supporter")
                    .padding(7)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.top, 30)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .fill(K.backgroundColor(for: 0, colorScheme: colorScheme))
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .black, location: 0.5)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    NavigationStack {
        ThemesView()
            .environmentObject(StoreManager())
    }
}
