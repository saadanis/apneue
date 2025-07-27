//
//  ContentView.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [Entry]
    
    @AppStorage("colorThemeIndex") var colorThemeIndex: Int = 0

    var body: some View {
        TimerView(colorThemeIndex: $colorThemeIndex)
            .tint(K.colorThemes[colorThemeIndex].accentColor)
    }

    private func addEntry() {
        withAnimation {
            let newEntry = Entry(duration: 25, mode: .maxHold)
            modelContext.insert(newEntry)
        }
    }

    private func deleteEntry(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
