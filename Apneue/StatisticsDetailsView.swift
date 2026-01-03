//
//  StatisticsDetailsView.swift
//  Apneue
//
//  Created by Saad Anis on 17/07/2025.
//

import SwiftUI
import SwiftData

struct StatisticsDetailsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    
    @State var mode: TimerMode
    
    @State var themeIndex: Int
    
    @Query var entries: [Entry]
    
    init(mode: TimerMode, themeIndex: Int) {
        self.mode = mode
        self.themeIndex = themeIndex
        _entries = Query(
            filter: #Predicate<Entry> { $0.mode == mode.rawValue },
            sort: \Entry.timestamp,
            order: .reverse
        )
    }
    
    @State private var isShowingDeleteAllDialog = false
    
    var body: some View {
        ThemedList(themeIndex: themeIndex) {
            Section("All Data") {
                if entries.isEmpty {
                    HStack {
                        Spacer()
                        Text("No entries.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Spacer()
                    }
                }
                ForEach(entries) { entry in
                    HStack {
                        Text(entry.duration.formattedTime)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                        Spacer()
                        Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                .onDelete(perform: deleteEntry)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            if editMode?.wrappedValue.isEditing == true {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Delete All") {
                        isShowingDeleteAllDialog = true
                    }
                    .confirmationDialog(
                        Text("Are you sure you want to delete all \(mode.rawValue.lowercased()) entries?"),
                        isPresented: $isShowingDeleteAllDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Delete All", role: .destructive) {
                            deleteAllEntries()
                        }
                    }
                }
            }
        }
        .navigationTitle(mode.rawValue)
        .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing == true)
    }
    
    private func deleteEntry(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
        }
    }
    
    private func deleteAllEntries() {
        withAnimation {
            entries.forEach(modelContext.delete)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Entry.self, configurations: config)
    
    let calendar = Calendar.current
    
    let numberOfEntries = 20
    
    let entries: [Entry] = (0..<numberOfEntries).map { _ in
        let randomDays = Int.random(in: 0...365)
        let randomDuration = Double.random(in: 0...120)
        return Entry(duration: randomDuration, mode: TimerMode.allCases.randomElement()!, timestamp: calendar.date(byAdding: .day, value: -randomDays, to: Date())!)
    }
    
    entries.forEach(container.mainContext.insert)
    
    return NavigationStack {
        StatisticsDetailsView(mode: .maxHold, themeIndex: 0)
            .tint(K.colorThemes[0].accentColor)
            .modelContainer(container)
    }
}
