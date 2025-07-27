//
//  ModesView.swift
//  Apneue
//
//  Created by Saad Anis on 02/06/2025.
//

import SwiftUI

struct ModesView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var timerMode: TimerMode
    
    var body: some View {
        NavigationStack {
            List {
                Section("Hold") {
                    ModeListItemView(timerMode: $timerMode, mode: .maxHold, dismiss: dismiss)
                }
                Section("Breathe") {
                    ModeListItemView(timerMode: $timerMode, mode: .boxBreathing, dismiss: dismiss)
                }
                Section("Tables") {
                    ModeListItemView(timerMode: $timerMode, mode: .co2Table, dismiss: dismiss)
                    ModeListItemView(timerMode: $timerMode, mode: .o2Table, dismiss: dismiss)
                }
            }
//            .scrollContentBackground(.hidden)
            .fontDesign(.rounded)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Choose a Mode")
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ModeListItemView: View {
    
    @Binding var timerMode: TimerMode
    let mode: TimerMode
    let dismiss: DismissAction
    
    @State var sheetIsPresented: Bool = false
    
    let modeDescriptions: [TimerMode: String] = [
        .maxHold: "Push your breath-hold to the limit for maximum endurance.",
        .boxBreathing: "Calm your mind with equal-paced inhale, hold, exhale, and hold.",
        .co2Table: "Build CO₂ tolerance with shorter rests between breath-holds.",
        .o2Table: "Boost oxygen endurance with long breath-holds and full recovery.",
    ]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(mode.rawValue)
                    .foregroundStyle(.primary)
                    .font(.headline)
                Text(modeDescriptions[mode]!)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            GlassEffectContainer {
                if mode != .maxHold {
                    Button {
                        sheetIsPresented = true
                    } label: {
                        Image(systemName:"gearshape")
                            .foregroundStyle(.foreground)
//                            .foregroundStyle(.foreground)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .tint(.secondary)
                    .glassEffect(.regular, in: .circle)
                }
                Button {
                    timerMode = mode
                    dismiss()
                } label: {
                    Text("Select")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .glassEffect(.regular.interactive())
            }
        }
//        .listRowBackground(Color.clear)
//        .listRowSeparator(.hidden)
        .sheet(isPresented: $sheetIsPresented) {
            Group {
                switch mode {
                case .boxBreathing:
                    BoxBreathingConfigurationView()
                        .presentationDetents([.fraction(0.7), .large])
                case .co2Table:
                    CO2TableConfigurationView()
                default:
                    Text("O2")
                }
            }
        }
    }
}

#Preview {
    struct Preview: View {
        
        @State var isShowingModesSheet = true
        @State var timerMode: TimerMode = .maxHold
        
        var body: some View {
            VStack{
                Color.accentColor
                .ignoresSafeArea()
            }
            .sheet(isPresented: $isShowingModesSheet) {
                ModesView(timerMode: $timerMode)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    return Preview()
}
