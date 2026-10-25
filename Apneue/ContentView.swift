//
//  ContentView.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
        NavigationStack {
            TimerView()
        }
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
            K.backgroundColor(for: themeIndex, colorScheme: colorScheme) :
                K.backgroundColor(for: themeIndex, colorScheme: colorScheme)
                .opacity(0.75)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
