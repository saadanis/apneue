//
//  OnboardingView.swift
//  Apneue
//
//  Created by Saad Anis on 27/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State var themeIndex: Int
    @State var pageNo: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ThemedList(themeIndex: themeIndex) {
                    VStack(alignment: .leading) {
                        switch pageNo {
                        case 0:
                            Group {
                                Text("Welcome to")
                                Text("Apneue")
                                    .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                            }
                        case 1:
                            Group {
                                Text("But first,")
                                Text("Safety First")
                                    .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                            }
                        default:
                            Group {
                                Text("You're all set.")
                                Text("Let's Begin!")
                                    .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                            }
                        }
                    }
                    .id(pageNo)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    if pageNo == 0 {
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "bubbles.and.sparkles", title: "Train Smarter", description: "Personalized breath-work tuned to your performance.")
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "wind", title: "Guided Breathing", description: "Smooth, paced sessions that keep your rhythm effortless.")
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "water.waves", title: "Build Real Capacity", description: "CO₂ and O₂ tables that steadily elevate your breath-hold power.")
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "chart.xyaxis.line", title: "Track Your Progress", description: "See improvements with clean, focused performance tracking.")
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "paintpalette", title: "Make It Yours", description: "Choose from vibrant themes to match your style.")
                    } else if pageNo == 1 {
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "person.badge.shield.checkmark", title: "Stay Supervised", description: "Always practice in a safe environment with proper supervision and never during any activity that could become dangerous if you lose consciousness.")
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "exclamationmark.triangle", title: "Know Your Limits", description: "Listen to your body and stop immediately if you feel anything abnormal; never push beyond safe limits.")
                        OnboardingListRowView(themeIndex: themeIndex, symbolName: "list.bullet.clipboard", title: "Follow Guidelines", description: "Follow all safety guidelines and use the app responsibly, especially if you have medical conditions or risk factors.")
                            .listRowBackground(Color.clear)
                    } else {
                        EmptyView()
                    }
                }
                VStack {
                    if pageNo == 1 {
                        Text("By continuing, you agree to take all the necessary safety precautions while using Apneue.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color.clear)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)
                    }
                    Button {
                        withAnimation(.easeInOut) {
                            pageNo += 1
                        }
                        if pageNo > 2 {
                            dismiss()
                        }
                    } label: {
                        Group {
                            switch pageNo {
                            case 0:
                                Text("Continue")
                            case 1:
                                Text("I Agree")
                            default:
                                Text("Start Training")
                            }
                        }
                        .padding(7)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                }
                .padding(.horizontal, 28)
                .padding(.top, 60)
            }
        }
    }
}

struct OnboardingListRowView: View {
    
    let themeIndex: Int
    let symbolName: String
    let title: String
    let description: String
    
    @State private var isVisible: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: symbolName)
                .font(.largeTitle)
                .frame(width: 40, alignment: .topTrailing)
                .fontWeight(.semibold)
                .foregroundColor(K.colorThemes[themeIndex].accentColor)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(description)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

#Preview {
    OnboardingView(themeIndex: 0)
}
