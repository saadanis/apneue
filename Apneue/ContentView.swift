//
//  ContentView.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("colorThemeIndex") private var storedColorThemeIndex: Int = 0

    var colorThemeIndex: Int {
        get { min(storedColorThemeIndex, K.colorThemes.count - 1) }
        set { storedColorThemeIndex = newValue }
    }

    var safeColorThemeIndexBinding: Binding<Int> {
        Binding(
            get: { colorThemeIndex },
            set: { storedColorThemeIndex = min($0, K.colorThemes.count - 1) }
        )
    }

    init() {
        var titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)

        titleFont = UIFont(
            descriptor:
                titleFont.fontDescriptor
                .withDesign(.rounded)?
                .withSymbolicTraits(.traitBold)
            ??
            titleFont.fontDescriptor,
            size: titleFont.pointSize
        )

        UINavigationBar.appearance().largeTitleTextAttributes = [.font: titleFont]

        let inlineFont = UIFont(
            descriptor:
                UIFont.preferredFont(forTextStyle: .headline)
                .fontDescriptor
                .withDesign(.rounded)?
                .withSymbolicTraits(.traitBold)
            ?? UIFont.preferredFont(forTextStyle: .headline).fontDescriptor,
            size: UIFont.preferredFont(forTextStyle: .headline).pointSize
        )

        UINavigationBar.appearance().titleTextAttributes = [.font: inlineFont]
    }

    var body: some View {
        TimerView(colorThemeIndex: safeColorThemeIndexBinding)
            .fontDesign(.rounded)
//            .symbolColorRenderingMode(.gradient)
    }
}

struct ThemedList<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let themeIndex: Int
    var isOpaque: Bool = true
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        List {
            content()
        }
        .scrollContentBackground(.hidden)
        .background(
            isOpaque ?
            K.colorThemes[themeIndex]
                .backgroundColors.first!
                .flattened(over:
                            colorScheme == .dark ?
                    .gray.darker(by: 50) :
                        .white, alpha: 0.1) :
                K.colorThemes[themeIndex]
                .backgroundColors.first!
                .opacity(0.1)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
