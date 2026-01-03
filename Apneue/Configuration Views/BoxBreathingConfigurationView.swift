//
//  BoxBreathingConfigurationView.swift
//  Apneue
//
//  Created by Saad Anis on 20/06/2025.
//

import SwiftUI

struct BoxBreathingConfigurationView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("boxBreathingDuration") var boxBreathingDuration: Double = 4
    @AppStorage("boxBreathingNumberOfRounds") var boxBreathingNumberOfRounds: Int = 8
    
    @State var themeIndex: Int
    
    var totalTime: TimeInterval {
        boxBreathingDuration * 4 * Double(boxBreathingNumberOfRounds)
    }
    
    var stringifiedTotalTime: String {
        let duration = Int(boxBreathingDuration)
        return "\(duration)→\(duration)→\(duration)→\(duration) (×\(boxBreathingNumberOfRounds))"
    }
    
    @State private var isRotated = false
    
    
    var body: some View {
        NavigationStack {
            ThemedList(themeIndex: themeIndex, isOpaque: false) {
                Text("Box Breathing is a controlled breathing technique where you inhale, hold, exhale, and hold again, each for an equal amount of time. This exercise helps calm the nervous system, improve focus, and increase tolerance to carbon dioxide.")
                    .listRowInsets(.horizontal, 0)
                    .listRowBackground(Color.clear)
                CustomTickerView(title: "Duration of Each Phase", value: $boxBreathingDuration, minValue: 2, maxValue: 10, stepSize: 1, isTimeInterval: true)
                CustomTickerView(title: "Number of Rounds", value: $boxBreathingNumberOfRounds, minValue: 2, maxValue: 30, stepSize: 1)
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("TOTAL SESSION LENGTH")
                            .fontWeight(.semibold)
                        Text(stringifiedTotalTime)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    Spacer()
                    Text("\(totalTime.formattedTime)")
                        .font(.title)
                        .fontWeight(.bold)
                        .animation(.smooth)
                    
                }
                .padding(.top)
                .listRowInsets(.horizontal, 0)
                .listRowBackground(Color.clear)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: {
                        isRotated.toggle()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            boxBreathingDuration = 4
                            boxBreathingNumberOfRounds = 10
                        }
                    }, label: {
                        Image(systemName: "arrow.counterclockwise")
                            .symbolEffect(.rotate, value: isRotated)
                    })
                }
            }
            .navigationTitle("Box Breathing")
            .listRowSpacing(10)
        }
    }
    
}

#Preview {
    BoxBreathingConfigurationView(themeIndex: 0)
}
