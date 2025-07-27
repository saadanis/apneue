//
//  TableConfigurationView.swift
//  Apneue
//
//  Created by Saad Anis on 20/06/2025.
//

import SwiftUI

struct CO2TableConfigurationView: View {
    
    @Environment(\.dismiss) var dismiss
    @Namespace private var namespace
    
    let maxHoldDuration = UserDefaults.standard.object(forKey: "maxHoldDuration") as! TimeInterval
    
    @State private var isRotated = false
    
    @AppStorage("co2NumberOfRounds") var co2NumberOfRounds: Int = 8
    @AppStorage("co2HoldPercentage") var co2HoldPercentage: Double = 0.5
    @AppStorage("co2RestStartingDuration") var co2RestStartingDuration: TimeInterval = 120
    @AppStorage("co2RestEndingDuration") var co2RestEndingDuration: TimeInterval = 15
    
    var tableConfiguration: TableConfiguration {
        .init(maxHoldDuration: maxHoldDuration, numberOfRounds: co2NumberOfRounds, restStartingDuration: co2RestStartingDuration, restEndingDuration: co2RestEndingDuration, holdPercentage: co2HoldPercentage)
    }
    
    var stringifiedTotalTime: String {
        let initialRest = co2RestStartingDuration.formattedTime
        let lastRest = co2RestEndingDuration.formattedTime
        let hold = (co2HoldPercentage * maxHoldDuration).formattedTime
        return "REST (\(initialRest)→\(lastRest))\nHOLD (\(hold))"
    }
    
    @State var isShowingPreviewSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Text("CO₂ Tables are designed to increase your tolerance to elevated carbon dioxide levels. Each round includes a fixed breath-hold time followed by progressively shorter rest periods. This trains your body to remain calm and efficient as CO₂ builds up.")
                    .listRowInsets(.horizontal, 0)
                    .listRowBackground(Color.clear)
                CustomTickerView(title: "Number of Rounds",
                                 value: $co2NumberOfRounds,
                                 minValue: 2,
                                 maxValue: 20)
                CustomTickerView(title: "Initial Rest Duration", value: $co2RestStartingDuration, minValue: co2RestEndingDuration + 15, maxValue: 300, stepSize: 15, isTimeInterval: true)
                CustomTickerView(title: "Final Rest Duration", value: $co2RestEndingDuration, minValue: 15, maxValue: co2RestStartingDuration - 15, stepSize: 15, isTimeInterval: true)
                CustomTickerView(title: "Hold Percentage of Max", value: $co2HoldPercentage, minValue: 0.2, maxValue: 1, stepSize: 0.1, isPercentage: true)
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
                            co2NumberOfRounds = 8
                            co2RestStartingDuration = 120
                            co2RestEndingDuration = 15
                            co2HoldPercentage = 0.5
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
            .navigationTitle("CO₂ Table")
            .listRowSpacing(10)
            .scrollContentBackground(.hidden)
            .background(Color.accentColor.opacity(0.08))
            .fontDesign(.rounded)
            .sheet(isPresented: $isShowingPreviewSheet) {
                TablePreviewView(numberOfRounds: tableConfiguration.numberOfRounds, restTimes: tableConfiguration.restTimes, holdTimes: tableConfiguration.holdTimes)
                .presentationDetents([.fraction(0.8), .large])
                .fontDesign(.rounded)
                .navigationTransition(.zoom(sourceID: "previewSheet", in: namespace))
            }
        }
    }
}

struct TablePreviewView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var numberOfRounds: Int
    var restTimes: [TimeInterval]
    var holdTimes: [TimeInterval]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("ROUND")
                            .frame(maxWidth: 90, alignment: .leading)
                        Spacer()
                        Text("REST")
                            .frame(maxWidth: 65)
                        Text("→")
                            .foregroundStyle(.clear)
                            .frame(maxWidth: 30)
                        Text("HOLD")
                            .frame(maxWidth: 65)
                    }
                }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowInsets(.vertical, 0)
                    .listRowBackground(Color.clear)
                
                    .listSectionSpacing(0)
                    ForEach(0..<numberOfRounds, id: \.self) { i in
                        HStack {
                            Text("Round \(i+1)")
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .frame(maxWidth: 90, alignment: .leading)
                            Spacer()
                            Text("\(restTimes[i].formattedTime)")
                                .monospacedDigit()
                                .frame(maxWidth: 65)
                            Text("→")
                                .frame(maxWidth: 30)
                            Text("\(holdTimes[i].formattedTime)")
                                .monospacedDigit()
                                .frame(maxWidth: 65)
                        }
                    }
            }
            .navigationTitle("Table Preview")
            .scrollContentBackground(.hidden)
            .background(Color.accentColor.opacity(0.08))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

enum CustomTickerType {
    case int
    case double
    case time
    case percentage
}


struct CustomTickerView: View {
    
    var title: String
    @Binding var value: Double
    let minValue: Double
    let maxValue: Double
    let stepSize: Double
    
    let tickerType: CustomTickerType
    
    init(title: String, value: Binding<Int>, minValue: Int, maxValue: Int, stepSize: Int = 1) {
        self.title = title
        self._value = Binding<Double>(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = Int($0) }
        )
        self.minValue = Double(minValue)
        self.maxValue = Double(maxValue)
        self.stepSize = Double(stepSize)
        self.tickerType = .int
    }
    
    init(title: String, value: Binding<Double>, minValue: Double, maxValue: Double, stepSize: Double = 1, isTimeInterval: Bool = false, isPercentage: Bool = false) {
        self.title = title
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepSize = stepSize
        self.tickerType = isTimeInterval ? .time : isPercentage ? .percentage : .double
    }
    
    var displayValue: String {
        switch tickerType {
        case .int:
            "\(Int(value))"
        case .double:
            "\(value)"
        case .time:
            "\(value.formattedTime)"
        case .percentage:
            String(format: "%.0f", value*100) + "%"
        }
    }
    
    var body: some View {
        HStack {
            Button {
                print(value, stepSize)
                value -= stepSize
                value = round(value * 100) / 100.0
            } label: {
                Image(systemName: "minus")
            }
            .frame(width: 36, height: 36, alignment: .center)
            .glassEffect(.regular.interactive(), in: Circle())
            .buttonStyle(.borderless)
            .disabled(value <= minValue)
            Spacer()
            VStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(displayValue)
                    .fontWeight(.semibold)
            }
            Spacer()
            Button {
                value += stepSize
                value = round(value * 100) / 100.0
            } label: {
                Image(systemName: "plus")
            }
            .frame(width: 36, height: 36, alignment: .center)
            .glassEffect(.regular.interactive(), in: Circle())
            .buttonStyle(.borderless)
            .disabled(value >= maxValue)
        }
    }
}

#Preview {
    CO2TableConfigurationView()
}
