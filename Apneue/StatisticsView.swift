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
    
    @AppStorage("maxHoldDuration") var maxHoldDuration: Double = 30
    @AppStorage("maxHoldDate") var maxHoldDate: Date = Date()
    
    @AppStorage("colorThemeIndex") var colorThemeIndex: Int = 0
    
    var chartBackgroundGradientArray: [Color] {
        Array(K.colorThemes[colorThemeIndex].backgroundColors.prefix(2))
    }
    
    var streak: (Int, Int) { calculateStreak() }
    
    var totalTime: TimeInterval {
        entries.map { entry in
            entry.duration
        }.reduce(0, +)
    }
    
    let data = (1...4).map { "Item \($0)" }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State var isPresented = false
    
    var body: some View {
        
        NavigationStack {
            List {
                Section("Summary") {
                    VStack {
                        HStack {
                            ListCardView(
                                title: "Current Streak",
                                image: "flame",
                                value: String(streak.0),
                                subvalue: streak.0 == 1 ? "day" : "days"
                            )
                            ListCardView(
                                title: "Longest Streak",
                                image: "trophy",
                                value: String(streak.1),
                                subvalue: streak.1 == 1 ? "day" : "days"
                            )
                        }
                        HStack {
                            ListCardView(
                                title: "Total Sessions",
                                image: "square.stack.3d.up",
                                value: String(entries.count),
                                subvalue: entries.count == 1 ? "session" : "sessions"
                            )
                            ListCardView(
                                title: "Total Time Trained",
                                image: "clock",
                                value: totalTime.formattedTime
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
                                    mode: mode
                                )
                            } else {
                                NavigationLink {
                                    StatisticsDetailsView(mode: mode)
                                } label: {
                                    LatestEntryWithChartView(
                                        entries: modeEntries,
                                        mode: mode
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
            .scrollContentBackground(.hidden)
            .background(Color.accentColor.opacity(0.08))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .close) {
                        dismiss()
                    }
                }
            }
            .fontDesign(.rounded)
        }
    }
    
    private func deleteEntry(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
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
        
        print("longestStreak", longestStreak)
        
        let yesterday = calendar.startOfDay(for: Date.now.addingTimeInterval(-86400))
        print("yesterday", yesterday.formatted(date: .abbreviated, time: .omitted))
        
        let today = calendar.startOfDay(for: Date())
        
        var streak = sortedDays.contains(today) ? 1 : 0
        
        for i in 0..<sortedDays.count {
            let expectedDay = calendar.date(byAdding: .day, value: -i, to: yesterday)!
            print("expected", expectedDay.formatted(date: .abbreviated, time: .omitted))
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

struct LatestEntryWithChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var entries: [Entry]
    
    var mode: TimerMode
    
    var lastSevenEntries: [Entry] {
        if entries.count <= 7 {
            entries.reversed()
        } else {
            Array(entries[0..<7]).reversed()
        }
    }
    
//    var lastSevenDays: [Date: Entry?] {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let lastSevenDates = (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: today)! }.reversed()
//        
//        var dict: [Date: Entry?] = [:]
//        for date in lastSevenDates {
//            let entryForDate = entries.first { calendar.isDate($0.timestamp, inSameDayAs: date) }
//            dict[date] = entryForDate
//        }
//        return dict
//    }
    
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
    
//    func shortenedSegment(from p1: (Double, Double), to p2: (Double, Double), shortenBy points: Double = 0.05) -> ((Double, Double), (Double, Double)) {
//        let dx = p2.0 - p1.0
//        let dy = p2.1 - p1.1
//        
//        let length = sqrt(dx*dx + dy*dy)
//        
//        print("length", length)
//        
////        guard length > points else {
////            // Cannot shorten more than the segment's length
////            return (p1, p2)
////        }
//        
//        let ux = dx / length
//        let uy = dy / length
//        
//        let newP1 = (p1.0 + ux * points/2, p1.1 + uy * points/2)
//        let newP2 = (p2.0 - ux * points/2, p2.1 - uy * points/2)
//        
//        let dxn = newP2.0 - newP1.0
//        let dyn = newP2.1 - newP1.1
//        
//        print("new length", sqrt(dxn*dxn + dyn*dyn))
//        
//        return (newP1, newP2)
//    }
    
    func shortenedSegment(from p1: (Double, Double), to p2: (Double, Double), baseFraction: Double = 0.5, scaling: Double = 100.0) -> ((Double, Double), (Double, Double)) {
        let dx = p2.0 - p1.0
        let dy = p2.1 - p1.1

        let length = sqrt(dx*dx + dy*dy)
        
        let fraction = baseFraction / (1.0 + length / scaling)
        
        let shortenX = dx * fraction
        let shortenY = dy * fraction

        let newP1 = (p1.0 + shortenX, p1.1 + shortenY)
        let newP2 = (p2.0 - shortenX, p2.1 - shortenY)
        return (newP1, newP2)
    }
    
    @State var isPressed = false
    
    var body: some View {
        
        let maxChartWidth: CGFloat = 80
        let entryCount: Int = lastSevenEntries.count
        let widthRatio: CGFloat = CGFloat(entryCount) / 7
        let chartWidth: CGFloat = maxChartWidth * min(widthRatio, 1)
        let secondaryColor: Color = colorScheme == .light ?
            .gray.darker(by: -30) :
            .gray.darker(by: 20)
        
        let calendar = Calendar.current
        
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Group {
                        Image(systemName: getSymbolForMode(mode))
                        Text(mode.rawValue)
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
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
                            let latest = calendar.isDate(
                                entry.timestamp,
                                inSameDayAs: latestEntry!.timestamp)
                            
                            if (index < lastSevenEntries.count - 1) {
                                
                                let segment = shortenedSegment(
                                    from: (Double(index), lastSevenEntries[index].duration),
                                    to: (Double(index+1), lastSevenEntries[index+1].duration),
                                    baseFraction: 0.2, scaling: 30)
                            
                                LineMark(
                                    x: .value("X", segment.0.0),
                                    y: .value("Y", segment.0.1)
                                )
                                .foregroundStyle(secondaryColor)
                                .foregroundStyle(by: .value("group", segment.0.0))
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                LineMark(
                                    x: .value("X", segment.1.0),
                                    y: .value("Y", segment.1.1)
                                )
                                .foregroundStyle(by: .value("group", segment.0.0))
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            }
                            
                            PointMark(
                                x: .value("Date", index),
                                y: .value("Duration", entry.duration)
                            )
                            .symbol {
                                Circle()
                                    .stroke(
                                        latest ?
                                        Color.accentColor :
                                            secondaryColor,
                                        lineWidth: 2
                                    )
                                    .frame(width: 6)
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
                                    Color.accentColor :
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
                    .foregroundStyle(Color.accentColor)
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
    
    return StatisticsView()
        .tint(K.colorThemes[0].accentColor)
        .modelContainer(container)
}
