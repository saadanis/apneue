//
//  Entry.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import Foundation
import SwiftData

@Model
final class Entry {
    #Index<Entry>([\.mode, \.timestamp], [\.timestamp])
    
    var timestamp: Date = Date.now
    var duration: TimeInterval = 0
    var mode: String = TimerMode.maxHold.rawValue
    var secondsFromGMT: Int?
    
    init(duration: TimeInterval, mode: TimerMode, timestamp: Date = Date()) {
        self.timestamp = timestamp
        self.duration = duration
        self.mode = mode.rawValue
        self.secondsFromGMT = TimeZone.current.secondsFromGMT(for: startDate)
    }
    
    var startDate: Date {
        timestamp.addingTimeInterval(-duration)
    }
    
    var day: Int {
        Entry.day(of: startDate, secondsFromGMT: secondsFromGMT)
    }
    
    func day(notAfter today: Int) -> Int {
        min(day, today)
    }
    
    static func day(of date: Date, secondsFromGMT: Int? = nil) -> Int {
        let offset = secondsFromGMT ?? TimeZone.current.secondsFromGMT(for: date)
        return Int(floor((date.timeIntervalSinceReferenceDate + Double(offset)) / 86_400))
    }
}

enum BreathStatus: String, CaseIterable {
    case inhale = "Inhale"
    case exhale = "Exhale"
    case hold = "Hold"
    case breathe = "Breathe"
    case rest = "Rest"
}

enum TimerMode: String, CaseIterable, Identifiable, Codable {
    case maxHold = "Max Hold"
    case boxBreathing = "Box Breathing"
    case co2Table = "CO₂ Table"
    case o2Table = "O₂ Table"
    
    var id: String { self.rawValue }
}
