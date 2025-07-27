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
    var timestamp: Date = Date.now
    var duration: TimeInterval = 0
    var mode: String = TimerMode.maxHold.rawValue
    
    init(duration: TimeInterval, mode: TimerMode, timestamp: Date = Date()) {
        self.timestamp = timestamp
        self.duration = duration
        self.mode = mode.rawValue
    }
}

@Model
final class Reminder {
    @Attribute(.unique) var id: String = ""
    var date: Date = Date.now
    
    init(id: String = UUID().uuidString, date: Date) {
        self.id = id
        self.date = date
    }
}

enum TimerStatus {
    case new
    case started
    case stopped
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
