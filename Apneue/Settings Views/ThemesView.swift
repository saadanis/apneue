//
//  ThemesView.swift
//  Apneue
//
//  Created by Saad Anis on 18/12/2025.
//

import SwiftUI

struct ThemesView: View {
    
    @Environment(\.dismiss) var dismiss
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
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.clear)
                                    .overlay {
                                        WaterView(
                                            waveColors: themes[i].waveColors,
                                            skyColors: themes[i].backgroundColors,
                                            isAnimated: themeIndex == i
                                        ) {
                                            EmptyView()
                                        } secondaryContent: {
                                            EmptyView()
                                        }
                                        .scaleEffect(0.4)
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
                                    .frame(height: 180)
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
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                            //                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isThemeAvailable(i))
                    }
                }
            }
        } else {
            // No-op if indices are invalid
            EmptyView()
        }
    }
    
    func isThemeAvailable(_ index: Int) -> Bool {
        index == 0 || store.isProUnlocked
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThemedList(themeIndex: themeIndex) {
                //            Section {
                //                if !store.isProUnlocked {
                //                    NavigationLink(destination: {
                //                        SupporterView()
                //                    }, label: {
                //                        VStack {
                //                            Text("Unlock All Themes")
                //                                .font(.headline)
                //                            Text("Become a supporter to unlock all these awesome themes!")
                //                                .multilineTextAlignment(.center)
                //                                .font(.subheadline)
                //                                .foregroundStyle(.secondary)
                //                        }
                //                        .frame(maxWidth: .infinity, alignment: . center)
                //                        .padding(.vertical)
                //                    })
                //                    .navigationLinkIndicatorVisibility(.hidden)
                //                }
                //            }
                themeSection("Simple", startIndex: 0, endIndex: 6)
                themeSection("A Little Less Simple", startIndex: 6, endIndex: 12)
                themeSection("Definitely Not Simple", startIndex: 12, endIndex: 18)
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
