//
//  StatisticsView.swift
//  Apneue
//
//  Created by Saad Anis on 05/06/2025.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("colorThemeIndex") private var themeIndex: Int = 0
    
    @Query(sort: \Entry.timestamp, order: .reverse) var entries: [Entry]
    
    @Query(
        filter: #Predicate<Entry> { $0.mode == "Max Hold" },
        sort: \Entry.timestamp,
        order: .reverse
    ) var maxHoldEntries: [Entry]
    
    @Query(
        filter: #Predicate<Entry> { $0.mode == "Box Breathing" },
        sort: \Entry.timestamp,
        order: .reverse
    ) var boxBreathingEntries: [Entry]
    
    @Query(
        filter: #Predicate<Entry> { $0.mode == "CO₂ Table" },
        sort: \Entry.timestamp,
        order: .reverse
    ) var co2Entries: [Entry]
    
    @Query(
        filter: #Predicate<Entry> { $0.mode == "O₂ Table" },
        sort: \Entry.timestamp,
        order: .reverse
    ) var o2Entries: [Entry]

    var streak: (Int, Int) { calculateStreak() }

    var totalTime: TimeInterval {
        entries.map { entry in
            entry.duration
        }.reduce(0, +)
    }
    
    var body: some View {
        NavigationStack {
            ThemedList(themeIndex: themeIndex) {
                Section("Summary") {
                    VStack {
                        HStack {
                            ListCardView(
                                title: "Current Streak",
                                image: "flame",
                                value: String(streak.0),
                                subvalue: streak.0 == 1 ? "day" : "days",
                                themeIndex: themeIndex
                            )
                            ListCardView(
                                title: "Longest Streak",
                                image: "trophy",
                                value: String(streak.1),
                                subvalue: streak.1 == 1 ? "day" : "days",
                                themeIndex: themeIndex
                            )
                        }
                        HStack {
                            ListCardView(
                                title: "Total Sessions",
                                image: "square.stack.3d.up",
                                value: String(entries.count),
                                subvalue: entries.count == 1 ? "session" : "sessions",
                                themeIndex: themeIndex
                            )
                            ListCardView(
                                title: "Total Time Trained",
                                image: "clock",
                                value: totalTime.formattedTime,
                                themeIndex: themeIndex
                            )
                        }
                    }
                    .listRowInsets(.all, 0)
                    .listRowBackground(Color.clear)
                }
                Section("All Data") {
                    
                    let modeToEntries: [TimerMode: [Entry]] = [
                        .maxHold : maxHoldEntries,
                        .boxBreathing : boxBreathingEntries,
                        .co2Table : co2Entries,
                        .o2Table : o2Entries
                    ]

                    ForEach(TimerMode.allCases, id: \.self) { mode in
                        if let modeEntries = modeToEntries[mode] {
                            if modeEntries.isEmpty {
                                LatestEntryWithChartView(
                                    entries: modeEntries,
                                    mode: mode,
                                    themeIndex: themeIndex
                                )
                            } else {
                                NavigationLink {
                                    StatisticsDetailsView(mode: mode, themeIndex: themeIndex)
                                } label: {
                                    LatestEntryWithChartView(
                                        entries: modeEntries,
                                        mode: mode,
                                        themeIndex: themeIndex
                                    )
                                }
                                .navigationLinkIndicatorVisibility(.hidden)
                            }
                        }
                    }
                }
            }
            .listRowSpacing(10)
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func calculateStreak() -> (Int, Int) {
        
        let calendar = Calendar.current
        
        let uniqueDays = Set(entries.map {
            calendar.startOfDay(for: $0.timestamp)
        })
        
        let sortedDays = uniqueDays.sorted(by: >)
        let longestStreak = calculateLongestStreak(dates: sortedDays.reversed())

        let yesterday = calendar.startOfDay(for: Date.now.addingTimeInterval(-86400))

        let today = calendar.startOfDay(for: Date())
        
        var streak = sortedDays.contains(today) ? 1 : 0
        
        for i in 0..<sortedDays.count {
            let expectedDay = calendar.date(byAdding: .day, value: -i, to: yesterday)!
            if sortedDays.contains(expectedDay) {
                streak += 1
            } else {
                break
            }
        }
        
        return (streak, max(streak, longestStreak))
    }
    
    private func calculateLongestStreak(dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<dates.count {
            let diff = calendar.dateComponents([.day], from: dates[i - 1], to: dates[i]).day ?? 0
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if diff > 1 {
                currentStreak = 1
            }
        }

        return maxStreak
    }
}

struct Donut: Shape {
    var holeRatio: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * holeRatio
        p.addEllipse(in: CGRect(x: rect.midX - outer,
                                y: rect.midY - outer,
                                width: outer * 2,
                                height: outer * 2))
        p.addEllipse(in: CGRect(x: rect.midX - inner,
                                y: rect.midY - inner,
                                width: inner * 2,
                                height: inner * 2))
        return p
    }
}

struct LatestEntryWithChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var entries: [Entry]
    
    var mode: TimerMode
    
    var themeIndex: Int
    
    var lastSevenEntries: [Entry] {
        if entries.count <= 7 {
            entries.reversed()
        } else {
            Array(entries[0..<7]).reversed()
        }
    }
    
    var lastSevenDays: [Date: Entry?] {
        guard let latestEntry = entries.max(by: { $0.timestamp < $1.timestamp }) else { return [:] }
        let calendar = Calendar.current
        let lastDate = calendar.startOfDay(for: latestEntry.timestamp)
        let lastSevenDates = (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: lastDate)! }.reversed()

        var dict: [Date: Entry?] = [:]
        for date in lastSevenDates {
            let entryForDate = entries.first { calendar.isDate($0.timestamp, inSameDayAs: date) }
            dict[date] = entryForDate
        }
        return dict
    }
    
    var latestEntry: Entry? {
        guard !entries.isEmpty else { return nil }
        return entries[0]
    }
    
    var body: some View {
        
        let maxChartWidth: CGFloat = 80
        let entryCount: Int = lastSevenEntries.count
        let widthRatio: CGFloat = CGFloat(entryCount) / 7
        let chartWidth: CGFloat = maxChartWidth * min(widthRatio, 1)
        let secondaryColor: Color = colorScheme == .light ?
            .gray.darker(by: -20) :
            .gray.darker(by: 20)
        
        let calendar = Calendar.current
        
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Group {
                        Image(systemName: getSymbolForMode(mode))
                        Text(mode.rawValue)
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                    Spacer()
                    if let latestEntry = latestEntry {
                        Group {
                            Text(latestEntry.timestamp.formatted(date: .numeric, time: .omitted))
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .font(.footnote)
                Spacer()
                HStack(alignment: .bottom) {
                    if let latestEntry = latestEntry {
                        VStack(alignment: .leading) {
                            Text("Latest")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(latestEntry.duration.formattedTime)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom, -5)
                    } else {
                        Text("No Entries")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    if mode == .maxHold {
                        Chart(Array(lastSevenEntries.enumerated()), id: \.element.timestamp) { index, entry in
                            let latest = entry.timestamp == latestEntry!.timestamp

                            LineMark(
                                x: .value("Date", index),
                                y: .value("Duration", entry.duration)
                            )
                            .foregroundStyle(secondaryColor)
                            .lineStyle(StrokeStyle(lineWidth: 2))

                            
                            PointMark(
                                x: .value("Date", index),
                                y: .value("Duration", entry.duration)
                            )
                            .symbol {
                                Circle()
                                    .fill(
                                        latest ?
                                        K.colorThemes[themeIndex].accentColor:
                                            secondaryColor
                                    )
//                                    .stroke(
//                                        latest ?
//                                        Color.accentColor :
//                                            secondaryColor,
//                                        lineWidth: 2
//                                    )
                                    .frame(width: 7)
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis(.hidden)
                        .chartLegend(.hidden)
                        .frame(width: chartWidth)
                        .padding(.top)
                        .padding(.trailing, 5)
                    } else {
                        Chart(Array(lastSevenDays.keys.enumerated()), id: \.element) { index, date in
                            if let entry = lastSevenDays[date] ?? nil {
                                BarMark(
                                    x: .value("Date", date),
                                    y: .value("Duration", entry.duration),
                                    width: 10
                                )
                                .foregroundStyle(
                                    calendar.isDate(
                                        date,
                                        inSameDayAs: latestEntry!.timestamp
                                    ) ?
                                    K.colorThemes[themeIndex].accentColor :
                                            secondaryColor
                                )
                            } else {
                                BarMark(
                                    x: .value("Date", date),
                                    y: .value("Duration", 0.0)
                                )
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis(.hidden)
                        .frame(width: 80)
                        .padding(.top)
                        .padding(.trailing, 5)
                    }
                }
            }
            .frame(height: 100)
    }
    
}

struct ListCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var image: String
    var value: String
    var subvalue: String?
    
    var themeIndex: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: image)
                Text(title)
            }
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            Spacer()
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(K.colorThemes[themeIndex].accentColor)
                if let subvalue = subvalue {
                    Text(subvalue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.bottom, -5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .padding(.horizontal)
        .padding(.vertical)
        .background {
            colorScheme == .light ?
            Color(uiColor: .systemBackground) :
            Color(uiColor: .secondarySystemBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
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
    
    //    let dates: [Date] = [
    //        Calendar.current.date(from: DateComponents(year: 2022, month: 10))!
    //    ]
    
    let moreEntries: [Entry] = [
        Entry(duration: 50, mode: .maxHold, timestamp: Date()),
        Entry(duration: 40, mode: .boxBreathing, timestamp: Date.now.addingTimeInterval(-86400*4)),
        Entry(duration: 20, mode: .maxHold, timestamp: Date.now.addingTimeInterval(-86400*2)),
        Entry(duration: 30, mode: .maxHold, timestamp: Date.now.addingTimeInterval(-86400*3)),
    ]
    
    let moreMoreEntries: [Entry] = [
        Entry(duration: 50, mode: .boxBreathing, timestamp: Date()),
        Entry(duration: 40, mode: .boxBreathing, timestamp: Date.now.addingTimeInterval(-86400*4)),
        Entry(duration: 20, mode: .boxBreathing, timestamp: Date.now.addingTimeInterval(-86400*2)),
        Entry(duration: 30, mode: .boxBreathing, timestamp: Date.now.addingTimeInterval(-86400*3)),
    ]
    
    entries.forEach(container.mainContext.insert)
    moreEntries.forEach(container.mainContext.insert)
    moreMoreEntries.forEach(container.mainContext.insert)
    
    struct Preview: View {
        
    @State var themeIndex = 0
        
        var container: ModelContainer
        
        var body: some View {
            StatisticsView()
                .tint(K.colorThemes[0].accentColor)
                .modelContainer(container)
        }
    }
    
    return Preview(container: container)
}
