//
//  O2TableConfigurationView.swift
//  Apneue
//
//  Created by Saad Anis on 22/06/2025.
//

import SwiftUI
import SwiftData

struct TableConfiguration {
    var numberOfRounds: Int
    
    var restTimes: [TimeInterval]
    var holdTimes: [TimeInterval]
    
    var joinedTimes: [TimeInterval] {
        zip(restTimes, holdTimes).flatMap { [$0, $1] }
    }
    
    var totalTime: TimeInterval {
        restTimes.reduce(0, +) + holdTimes.reduce(0, +)
    }
    
    init(
        maxHoldDuration: TimeInterval,
        numberOfRounds: Int,
        restDuration: TimeInterval,
        holdStartingPercentage: Double,
        holdEndingPercentage: Double
    ) {
        let start = Double(maxHoldDuration)*holdStartingPercentage
        let end = Double(maxHoldDuration)*holdEndingPercentage
        let holdStep = (end - start) / Double(numberOfRounds - 1)
        
        self.numberOfRounds = numberOfRounds
        self.restTimes = Array(repeating: round(restDuration), count: numberOfRounds)
        self.holdTimes = (0..<numberOfRounds).map {
            round(Double(maxHoldDuration)*holdStartingPercentage + Double($0)*holdStep)
        }
    }
    
    init(
        maxHoldDuration: TimeInterval,
        numberOfRounds: Int,
        restStartingDuration: TimeInterval,
        restEndingDuration: TimeInterval,
        holdPercentage: Double
    ){
        let co2RestStep = (restStartingDuration - restEndingDuration) / Double(numberOfRounds - 1)
        
        self.numberOfRounds = numberOfRounds
        self.restTimes = (0..<numberOfRounds).map { round(restStartingDuration - co2RestStep*Double($0)) }
        self.holdTimes = Array(repeating: round(holdPercentage * maxHoldDuration), count: numberOfRounds)
    }
}

struct O2TableConfigurationView: View {
    
    @Environment(\.dismiss) var dismiss
    @Namespace private var namespace
    
    private static var maxHoldDescriptor: FetchDescriptor<Entry> = {
        var descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { $0.mode == "Max Hold" },
            sortBy: [SortDescriptor(\.duration, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }()
    
    @Query(Self.maxHoldDescriptor) var maxHoldEntry: [Entry]
    
    var maxHoldDuration: TimeInterval {
        maxHoldEntry.first?.duration ?? 0
    }
    
    @State var isRotated = false
    
    @AppStorage("o2NumberOfRounds") var o2NumberOfRounds: Int = 8
    @AppStorage("o2RestDuration") var o2RestDuration: TimeInterval = 75
    @AppStorage("o2HoldStartingPercentage") var o2HoldStartingPercentage: Double = 0.5
    @AppStorage("o2HoldEndingPercentage") var o2HoldEndingPercentage: Double = 1.0
    
    var tableConfiguration: TableConfiguration {
        .init(maxHoldDuration: maxHoldDuration, numberOfRounds: o2NumberOfRounds, restDuration: o2RestDuration, holdStartingPercentage: o2HoldStartingPercentage, holdEndingPercentage: o2HoldEndingPercentage)
    }
    
    var stringifiedTotalTime: String {
        let rest = o2RestDuration.formattedTime
        let initialHold = (Double(maxHoldDuration)*o2HoldStartingPercentage).formattedTime
        let finalHold = (Double(maxHoldDuration)*o2HoldEndingPercentage).formattedTime
        return "REST (\(rest))\nHOLD (\(initialHold)→\(finalHold))"
    }
    
    @State var isShowingPreviewSheet = false
    
    @State var themeIndex: Int
    
    var body: some View {
        NavigationStack {
            ThemedList(themeIndex: themeIndex, isOpaque: false) {
                Text("O₂ Tables focus on enhancing your body’s ability to function with lower oxygen levels. In this mode, rest periods remain constant while breath-hold durations gradually increase. This helps build hypoxia tolerance and improve overall breath-hold performance.")
                    .listRowInsets(.horizontal, 0)
                    .listRowBackground(Color.clear)
                CustomTickerView(title: "Number of Rounds",
                                 value: $o2NumberOfRounds,
                                 minValue: 2,
                                 maxValue: 20)
                CustomTickerView(title: "Fixed Rest Duration", value: $o2RestDuration,
                                 minValue: 15, maxValue: 600, stepSize: 15, isTimeInterval: true)
                CustomTickerView(title: "Initial Hold Percentage of Max", value: $o2HoldStartingPercentage, minValue: 0.05, maxValue: o2HoldEndingPercentage - 0.05, stepSize: 0.05, isPercentage: true)
                CustomTickerView(title: "Final Hold Percentage of Max", value: $o2HoldEndingPercentage, minValue: o2HoldStartingPercentage + 0.05, maxValue: 1.5, stepSize: 0.05, isPercentage: true)
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("TOTAL SESSION LENGTH")
                            .fontWeight(.semibold)
                        Text(stringifiedTotalTime)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    Spacer()
                    Text("\(tableConfiguration.totalTime.formattedTime)")
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
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isRotated.toggle()
                            o2NumberOfRounds = 8
                            o2RestDuration = 75
                            o2HoldStartingPercentage = 0.5
                            o2HoldEndingPercentage = 1
                        }
                    }, label: {
                        Image(systemName: "arrow.counterclockwise")
                            .symbolEffect(.rotate, value: isRotated)
                    })
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isShowingPreviewSheet = true
                    } label: {
                        Label("Preview Table", systemImage: "tablecells")
                    }
                }
                .matchedTransitionSource(id: "previewSheet", in: namespace)
            }
            .navigationTitle("O₂ Table")
            .listRowSpacing(10)
            .sheet(isPresented: $isShowingPreviewSheet) {
                TablePreviewView(numberOfRounds: o2NumberOfRounds, restTimes: tableConfiguration.restTimes, holdTimes: tableConfiguration.holdTimes, themeIndex: themeIndex)
                .presentationDetents([.fraction(0.8)])
                .navigationTransition(.zoom(sourceID: "previewSheet", in: namespace))
            }
        }
    }
}

#Preview {
    O2TableConfigurationView(themeIndex: 0)
}
