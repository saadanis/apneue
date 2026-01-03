//
//  UsageView.swift
//  Apneue
//
//  Created by Saad Anis on 18/07/2025.
//

import SwiftUI

struct UsageView: View {

    @State var themeIndex: Int
    
    var body: some View {
        ThemedList(themeIndex: themeIndex) {
            Section {
                ListRowView(text: "This is your baseline and progress tracker to calculate your maximum breath-holding capacity.", font: .headline, hideBackground: false)
                ListRowView(text: "When ready, press start to begin. Then hold your breath as long as you comfortably can.", image: "play", hideBackground: false)
                ListRowView(text: "Press stop when you stop holding; and your time will be saved. Your personal best will be used to personalize your training tables.", image: "stop", hideBackground: false)
            } header: {
                    Label("Max Hold", systemImage: "timer")
                    .labelIconToTitleSpacing(8)
            }
            Section {
                ListRowView(text: "Box breathing is a paced-breathing technique that regulates respiration by cycling through equal-length phases of inhaling, holding, exhaling, and holding again.", font: .headline, hideBackground: false)
                ListRowView(text: "Press start to begin. The sequence will automatically guide you through each phase in order for the selected number of rounds.", image: "play", hideBackground: false)
                ListRowView(text: "Use the options menu to configure the total number of rounds and the duration of one phase.", image: "slider.horizontal.3", hideBackground: false)
            } header: {
                Label("Box Breathing", systemImage: "cube")
                    .labelIconToTitleSpacing(8)
            }
            Section {
                ListRowView(text: "CO₂ tables are breath-training protocols designed to increase tolerance to elevated carbon dioxide levels by keeping the breath-hold duration fixed while gradually reducing rest intervals across rounds.", font: .headline, hideBackground: false)
                ListRowView(text: "This feature unlocks only after completing a max-hold test. The max-hold value is required to calculate your session parameters.", image: "lock.open", hideBackground: false)
                ListRowView(text: "Press start to begin. The session will guide you through each round with its corresponding hold and rest periods.", image: "play", hideBackground: false)
                ListRowView(text: "Use the options menu to configure the number of rounds, the initial and final rest durations, and the hold percentage of your max hold time.", image: "slider.horizontal.3", hideBackground: false)
                ListRowView(text: "Intermediate rest durations are interpolated automatically between the initial and final values.", image: "arrow.up.right.and.arrow.down.left", hideBackground: false)
                ListRowView(text: "A preview table is available to display all calculated rounds, including hold times and rest intervals.", image: "table", hideBackground: false)
            } header: {
                Label("CO₂ Table", systemImage: "water.waves.and.arrow.trianglehead.down")
                    .labelIconToTitleSpacing(8)
            }
            Section {
                ListRowView(text: "O₂ tables are breath-training protocols designed to increase tolerance to low oxygen levels by keeping rest intervals fixed while progressively increasing breath-hold durations across rounds.", font: .headline, hideBackground: false)
                ListRowView(text: "This feature unlocks only after completing a max-hold test. The max-hold value is required to calculate your session parameters.", image: "lock.open", hideBackground: false)
                ListRowView(text: "Press start to begin. The session will guide you through each round’s fixed rest period followed by its assigned breath-hold duration.", image: "play", hideBackground: false)
                ListRowView(text: "Use the options menu to configure the number of rounds, the fixed rest duration and the starting and ending hold percentages of your max hold time.", image: "slider.horizontal.3", hideBackground: false)
                ListRowView(text: "Intermediate hold durations are interpolated automatically between the starting and ending percentages.", image: "arrow.up.right.and.arrow.down.left", hideBackground: false)
                ListRowView(text: "A preview table is available to display all calculated rounds, including hold times and rest intervals.", image: "table", hideBackground: false)
            } header: {
                Label("O₂ Table", systemImage: "water.waves.and.arrow.trianglehead.up")
                    .labelIconToTitleSpacing(8)
            }
        }
        .navigationTitle("Usage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ListRowView: View {
    
    @State var text: String
    @State var image: String? = nil
    @State var font: Font = .body
    
    @State var hideBackground: Bool = true
    
    var body: some View {
        Group {
            if let image = image {
                Label(text, systemImage: image)
            } else {
                Text(text)
            }
        }
        .listRowBackground(hideBackground ? Color.clear : nil)
        .listRowSeparator(hideBackground ? .hidden : .automatic)
        .font(font)
    }
}

#Preview {
    NavigationStack {
        UsageView(themeIndex: 0)
    }
}
