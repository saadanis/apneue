//
//  SafetyView.swift
//  Apneue
//
//  Created by Saad Anis on 16/11/2025.
//

import SwiftUI

struct SafetyView: View {
    
    @State var themeIndex: Int
    
    var body: some View {
        ThemedList(themeIndex: themeIndex) {
                Text("Static-apnea training carries real risks, so make sure you follow all of these precautions every time you use the app.")
                    .fontWeight(.medium)
                    .padding(.bottom, 5)
                    .listRowInsets(.horizontal, 0)
                    .listRowBackground(Color.clear)
            Section {
                ListRowView(text: "Never practice breath-holding alone. Always have direct, in-person supervision.", image: "person", hideBackground: false)
                ListRowView(text: "Use the app only while seated or lying down, and never in water, while driving, or during any task that could become dangerous if you lose consciousness.", image: "chair.lounge", hideBackground: false)
                ListRowView(text: "Stop immediately if you feel dizziness, confusion, chest pain, numbness, nausea, or any unusual discomfort.", image: "xmark.octagon", hideBackground: false)
                ListRowView(text: "Do not hyperventilate. Breathe normally before starting unless you are following a protocol under qualified guidance.", image: "wind", hideBackground: false)
                ListRowView(text: "Allow full recovery between breath-holds and avoid pushing past your known limits.", image: "arrow.counterclockwise", hideBackground: false)
                ListRowView(text: "Do not train when fatigued, dehydrated, sick, intoxicated, or under the influence of substances.", image: "wineglass", hideBackground: false)
                ListRowView(text: "Anyone with cardiovascular, respiratory, neurological, clotting-related, or other relevant medical conditions should seek professional guidance before apnea training.", image: "lungs", hideBackground: false)
                ListRowView(text: "If you ever train in water in any context, ensure constant supervision by someone trained in rescue and safety.", image: "water.waves", hideBackground: false)
                ListRowView(text: "Use the app and perform breath-hold training at your own risk, and prioritize conservative, safe practice.", image: "heart", hideBackground: false)
            }
        }
        .listSectionSpacing(10)
        .navigationTitle("Safety")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SafetyView(themeIndex: 0)
    }
}
