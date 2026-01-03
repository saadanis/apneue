//
//  TipView.swift
//  Apneue
//
//  Created by Saad Anis on 18/12/2025.
//

import SwiftUI
import StoreKit

struct SupporterView: View {
    @State private var showingSignIn = false
    @AppStorage("colorThemeIndex") private var themeIndex: Int = 0
    
    @EnvironmentObject var store: StoreManager
    
    let themes = K.colorThemes
    let themesCount = K.colorThemes.count
    let appIconNames = K.appIconNames
    
    private let hearts: [(size: CGFloat, rotation: Double, yOffset: CGFloat)] = [
        (28, -18,  2),
        (36,   8, -1),
        (50, -10,  0),
        (40,  22,  3),
        (32,  -6, -2),
        (44,  14,  1),
        (24,  12, -3),
        (38, -25,  4),
        (46,   5, -1),
        (34,  18,  2),
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThemedList(themeIndex: themeIndex) {
                VStack(spacing: 10) {
                    HStack {
                        
                    }
                    .frame(height: 110)
                    .background {
                        HStack {
                            ForEach([2, 13, 12, 14, 15, 17], id: \.self) { i in
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.clear)
                                    .overlay {
                                        WaterView(
                                            waveColors: themes[i].waveColors,
                                            skyColors: themes[i].backgroundColors,
                                        ) {
                                            EmptyView()
                                        } secondaryContent: {
                                            EmptyView()
                                        }
                                        .scaleEffect(0.4)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .frame(width: 70, height: 110)
                            }
                        }
                    }
                    .padding(.bottom)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Unlock All Themes")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                        Text("Support the developer and unlock access to all themes, including all future additions.")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 10) {
                    HStack {
                        
                    }
                    .frame(height: 60)
                    .background {
                        HStack {
                            ForEach([1, 3, 4, 5, 6, 7, 8], id: \.self) { i in
                                Image(appIconNames[i])
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            }
                        }
                    }
                    .padding(.bottom)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Unlock Alternate Icons")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                        Text("Unlock all alternate app icons to customize your home screen.")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 10) {
                    HStack {
                        
                    }
                    .frame(height: 45)
                    .background {
                        HStack(spacing: 5) {
                            ForEach(Array(hearts.enumerated()), id: \.offset) { _, h in
                                Image(systemName: "heart.fill")
//                                    .font(.system(size: h.size, weight: .heavy))
                                    .font(.system(size: h.size, weight: .semibold, design: .rounded))
                                    .rotationEffect(.degrees(h.rotation))
                                    .offset(y: h.yOffset)
                                    .foregroundStyle(.pink)
                                    .symbolColorRenderingMode(.gradient)
                                    .shadow(color: .pink, radius: 4, x: 0, y: 0)
                            }
                        }
                    }
                    .padding(.bottom)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Support Development")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.pink)
                        Text("Support the continuous development of Apneue, and yours truly.")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .listRowSpacing(15)
                VStack(spacing: 10) {
                    ProductView(id: "com.saadanis.Apneue.Supporter")
                        .productViewStyle(CustomProductStyle(themeIndex: themeIndex))
                    HStack {
                        Text("Already a supporter?")
                        Button("Restore purchase.") {
                            Task {
                                await store.restorePurchases()
                            }
                        }
                        .disabled(store.isProUnlocked)
                    }
                    .font(.caption)
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
                                    .init(color: .black, location: 0.3)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                }
        }
        .navigationTitle("Support Apneue")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.refreshEntitlements()
        }
    }
}

struct CustomProductStyle: ProductViewStyle {
    
    @State var themeIndex: Int
    @EnvironmentObject var store: StoreManager
    
    func makeBody(configuration: Configuration) -> some View {
        switch configuration.state {
        case .loading:
            ProgressView()
                .padding(7)
                .frame(maxWidth: .infinity)
        case .success(let product):
            Button {
                configuration.purchase()
            } label: {
                HStack(alignment: .center) {
                    if store.isProUnlocked {
                        Text("Thanks for supporting Apnueue!")
                            .fontWeight(.semibold)
                    } else {
                        Text("One-Time Purchase")
                            .font(.callout)
                        Spacer()
                        Text(verbatim: product.displayPrice)
                            .fontWeight(.semibold)
                    }
                }
                .padding(7)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(store.isProUnlocked)
        default:
            Text("Something went wrong.")
                .padding(7)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    NavigationStack {
        SupporterView()
            .tint(.blue)
            .environmentObject(StoreManager())
    }
}
