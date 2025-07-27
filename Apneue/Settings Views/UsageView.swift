//
//  UsageView.swift
//  Apneue
//
//  Created by Saad Anis on 18/07/2025.
//

import SwiftUI

struct UsageView: View {
    
    var body: some View {
        List {
            Section {
                Text("Apneue is designed to help you train static apnea—holding your breath while staying still—used in freediving and CO₂/O₂ tolerance training. It guides you through three core functions: testing your max hold, perform breathing exercises, and practice training tables.")
                    .fontWeight(.semibold)
                    .listRowBackground(Color.clear)
            }
            Section("Max Hold") {
                ListRowView(text: "This is your baseline and progress tracker.", font: .headline)
                ListRowView(text: "Press start, then hold your breath as long as you can.", image: "1.circle")
                ListRowView(text: "Press stop when you stop holding; and your time will be saved.", image: "2.circle")
                ListRowView(text: "Your best result will be used to personalize your training tables.", image: "3.circle")
            }
        }
        .listRowSeparator(.hidden)
        .navigationTitle("Usage")
        .scrollContentBackground(.hidden)
        .background(Color.accentColor.opacity(0.08))
    }
}

struct ListRowView: View {
    
    @State var text: String
    @State var image: String? = nil
    @State var font: Font = .body
    
    
    var body: some View {
        Group {
            if let image = image {
                Label(text, systemImage: image)
            } else {
                Text(text)
            }
        }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .font(font)
    }
}

#Preview {
    NavigationStack {
        UsageView()
    }
}
