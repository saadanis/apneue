//
//  TipView.swift
//  Apneue
//
//  Created by Saad Anis on 18/12/2025.
//

import SwiftUI
import StoreKit

struct SupporterView: View {
    private struct StoreAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    
    @State private var showingSignIn = false
    @State private var storeAlert: StoreAlert?
    @Environment(\.themeIndex) private var themeIndex
    
    @EnvironmentObject var store: StoreManager
    @Environment(\.colorScheme) var colorScheme
    
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
    
    @ViewBuilder private func listItem(title: String, message: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                .symbolColorRenderingMode(.gradient)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                    Rectangle()
                    .overlay(alignment: .top) {
                        VStack {
                            HStack {
                                ForEach([1, 2, 3, 4, 5, 6], id: \.self) { i in
                                    SimplerThemeView(themeIndex: i, height: 120)
                                        .frame(width: 75)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: K.colorThemes[i].accentColor.opacity(0.3), radius: 60)
                                        .offset(y: i%2 == 0 ? 0 : -10)
                                }
                            }
                            HStack(spacing: 12) {
                                ForEach([5, 6, 2, 7, 8], id: \.self) { i in
                                    if i == 2 {
                                        Text("Support Apneue")
                                            .foregroundStyle(
                                                colorScheme == .dark ?
                                                    .white :
                                                        .black
                                            )
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .frame(width: 200)
                                            .multilineTextAlignment(.center)
                                        
                                    } else {
                                        Image(appIconNames[i])
                                            .resizable()
                                            .frame(width: 70, height: 70)
                                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
                                            .offset(y: i%2 == 0 ? 5 : -5)
                                    }
                                }
                            }
                            .frame(height: 75)
                            HStack {
                                ForEach([12, 13, 14, 15, 16, 17], id: \.self) { i in
                                    SimplerThemeView(themeIndex: i, height: 120)
                                        .frame(width: 75)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: K.colorThemes[i].accentColor.opacity(0.3), radius: 60)
                                        .offset(y: i%2 == 0 ? 0 : 10)
                                }
                            }
                        }
                    }
                        .foregroundStyle(.clear)
                        .frame(height: 400)
                        .ignoresSafeArea(edges: .top)
                VStack(alignment: .leading, spacing: 20) {
                    listItem(
                        title: "Unlock All Themes",
                        message: "Make Apneue feel truly yours with over fifteen fun and colorful themes.", icon: "1.circle.fill"
                    )
                    listItem(
                        title: "Unlock Alternate Icons",
                        message: "Switch up your app icon and match whatever vibe your homescreen is in.", icon: "2.circle.fill"
                    )
                    listItem(
                        title: "Support Development",
                        message: "Support Apneue’s continued development and the lone lost soul behind it.",
                        icon: "3.circle.fill"
                    )
                }
                .padding(.horizontal, 28)
                VStack {
                    
                }
                .frame(height: 80)
                
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            VStack(spacing: 10) {
                if store.isProUnlocked {
                    Button { } label: {
                        HStack {
                            Text("Thanks for supporting Apneue.")
                                .fontWeight(.semibold)
                        }
                        .padding(7)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(true)
                } else if let product = store.product {
                    Button {
                        Task {
                            switch await store.buy() {
                            case .success, .cancelled:
                                break
                            case .pending:
                                storeAlert = StoreAlert(
                                    title: "Purchase Pending",
                                    message: "Your purchase is waiting for approval. Apneue will unlock automatically once it's approved."
                                )
                            case .unavailable:
                                storeAlert = StoreAlert(
                                    title: "Purchase Unavailable",
                                    message: "Couldn't reach the App Store. Please check your connection and try again."
                                )
                            case .failed(let error):
                                storeAlert = StoreAlert(
                                    title: "Purchase Unsuccessful",
                                    message: error.localizedDescription
                                )
                            }
                        }
                    } label: {
                        HStack {
                            if store.isPurchasing {
                                ProgressView()
                            } else {
                                Text("One-Time Purchase").font(.callout)
                            }
                            if !store.isPurchasing {
                                Spacer()
                                Text(verbatim: product.displayPrice)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(7)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(store.isPurchasing)

                } else {
                    Button {
                        Task { await store.loadProduct() }
                    } label: {
                        HStack {
                            if store.isLoadingProduct {
                                ProgressView()
                            } else {
                                Text("Try Again").font(.callout)
                            }
                        }
                        .padding(7)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(store.isLoadingProduct)
                }
                HStack {
                    Text("Already a supporter?")
                    Button {
                        Task {
                            switch await store.restorePurchases() {
                            case .restored, .cancelled:
                                break
                            case .noPurchasesFound:
                                storeAlert = StoreAlert(
                                    title: "No Purchase Found",
                                    message: "There's no Apneue supporter purchase on this Apple Account. If you bought it with a different account, sign in with that one and try again."
                                )
                            case .failed(let error):
                                storeAlert = StoreAlert(
                                    title: "Restore Unsuccessful",
                                    message: error.localizedDescription
                                )
                            }
                        }
                    } label: {
                        if store.isRestoring {
                            HStack(spacing: 4) {
                                ProgressView().scaleEffect(0.7)
                                Text("Restoring…")
                            }
                        } else {
                            Text("Restore purchase.")
                        }
                    }
                    .disabled(store.isProUnlocked || store.isRestoring)
                }
                .font(.caption)
                .frame(height: 23)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 28)
            .padding(.top, 30)
            .background {
                Rectangle()
                    .fill(.thinMaterial)
                    .fill(K.backgroundColor(for: themeIndex, colorScheme: colorScheme))
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
        .background(K.backgroundColor(for: themeIndex, colorScheme: colorScheme))
        .toolbarBackground(.visible, for: .navigationBar)
//        .navigationTitle("Support Apneue")
//        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.refreshEntitlements()
            if store.product == nil {
                await store.loadProduct()
            }
        }
        .alert(
            storeAlert?.title ?? "",
            isPresented: Binding(get: { storeAlert != nil }, set: { if !$0 { storeAlert = nil } }),
            presenting: storeAlert
        ) { _ in
            Button("OK", role: .cancel) { }
        } message: { alert in
            Text(alert.message)
        }
    }
}

#Preview {
    NavigationStack {
        SupporterView()
            .tint(.blue)
            .environmentObject(StoreManager())
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Back", systemImage: "heart.fill") {
                        
                    }
                }
            }
    }
}
