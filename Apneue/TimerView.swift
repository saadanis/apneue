//
//  TimerView.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData
import CoreHaptics
import AVFoundation

struct TimerConfiguration {
    var numberOfRounds: Int
    var roundLength: Int
    var durations: [TimeInterval]
    var breathStatuses: [BreathStatus]
}

func getSymbolForMode(_ mode: TimerMode) -> String {
    switch mode {
        case .maxHold:
            "timer"
        case .boxBreathing:
            "cube"
        case .co2Table:
            "water.waves.and.arrow.trianglehead.down"
        case .o2Table:
            "water.waves.and.arrow.trianglehead.up"
    }
}

struct TimerView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Namespace private var namespace
    
    @StateObject var healthKitManager = HealthKitManager.shared
    
    @State private var audioPlayer: AVAudioPlayer?
    
    @State private var engine: CHHapticEngine?
    
    @AppStorage("syncToHealthKit") var syncToHealthKit: Bool = false
    @AppStorage("syncHoldToHK") var syncHoldToHK: Bool = false
    @AppStorage("syncBreathingToHK") var syncBreathingToHK: Bool = false
    @AppStorage("syncTablesToHK") var syncTablesToHK: Bool = false
    
    // Setup options.
    @AppStorage("maxHoldDuration") var maxHoldDuration: Double = 0
    @AppStorage("maxHoldDate") var maxHoldDate: Date = Date()
    
    @AppStorage("boxBreathingDuration") var boxBreathingDuration: Double = 4
    @AppStorage("boxBreathingNumberOfRounds") var boxBreathingNumberOfRounds: Int = 8
    
    @AppStorage("co2NumberOfRounds") var co2NumberOfRounds: Int = 8
    @AppStorage("co2HoldPercentage") var co2HoldPercentage: Double = 0.5
    @AppStorage("co2RestStartingDuration") var co2RestStartingDuration: TimeInterval = 120
    @AppStorage("co2RestEndingDuration") var co2RestEndingDuration: TimeInterval = 15
    
    @AppStorage("o2NumberOfRounds") var o2NumberOfRounds: Int = 8
    @AppStorage("o2RestDuration") var o2RestDuration: TimeInterval = 75
    @AppStorage("o2HoldStartingPercentage") var o2HoldStartingPercentage: Double = 0.5
    @AppStorage("o2HoldEndingPercentage") var o2HoldEndingPercentage: Double = 1.0
    
    @AppStorage("skipInitialRest") var skipInitialRest: Bool = true

    // Color palette options.
    @Binding var colorThemeIndex: Int
    
    var accentColor: Color {
        K.colorThemes[colorThemeIndex].accentColor
    }
    
    @State private var timerMode: TimerMode = TimerMode(
        rawValue: UserDefaults.standard.string(
            forKey: "defaultTimerMode"
        ) ?? ""
    ) ?? TimerMode(
        rawValue: UserDefaults.standard.string(
            forKey: "lastUsedMode"
        ) ?? ""
    ) ?? .boxBreathing
    
    @State var isUnderwater: Bool = false
    
    private var timerConfiguration: TimerConfiguration? {
        if timerMode == .boxBreathing {
            let breathLoop: [BreathStatus] = [.inhale, .hold, .exhale, .hold]
            return TimerConfiguration(
                numberOfRounds: boxBreathingNumberOfRounds,
                roundLength: 4,
                durations: Array(repeating: boxBreathingDuration, count: boxBreathingNumberOfRounds*4),
                breathStatuses: Array(repeating: breathLoop, count: boxBreathingNumberOfRounds).flatMap { $0 }
            )
        } else if timerMode == .co2Table {
            let tableConfiguration = TableConfiguration(maxHoldDuration: maxHoldDuration, numberOfRounds: co2NumberOfRounds, restStartingDuration: co2RestStartingDuration, restEndingDuration: co2RestEndingDuration, holdPercentage: co2HoldPercentage)
            let breathLoop: [BreathStatus] = [.breathe, .hold]
            return TimerConfiguration(numberOfRounds: co2NumberOfRounds, roundLength: 2, durations: tableConfiguration.joinedTimes, breathStatuses: Array(repeating: breathLoop, count: co2NumberOfRounds).flatMap { $0 })
        } else if timerMode == .o2Table {
            let tableConfiguration = TableConfiguration(maxHoldDuration: maxHoldDuration, numberOfRounds: o2NumberOfRounds, restDuration: o2RestDuration, holdStartingPercentage: o2HoldStartingPercentage, holdEndingPercentage: o2HoldEndingPercentage)
            let breathLoop: [BreathStatus] = [.breathe, .hold]
            return TimerConfiguration(numberOfRounds: o2NumberOfRounds, roundLength: 2, durations: tableConfiguration.joinedTimes, breathStatuses: Array(repeating: breathLoop, count: o2NumberOfRounds).flatMap { $0 })
        }
        return nil
    }
    
    @State private var isTimerRunning: Bool = false
    
    // Primary timer that runs throughout the session.
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var startTime: Date?
    
    // Phase timer that runs on phased sessions.
    @State private var phaseTimer: Timer?
    @State private var phaseStartTime: Date?
    @State private var phaseEndTime: Date?
    @State private var phaseTimeRemaining: TimeInterval = 0
    private var phaseTotalTime: TimeInterval {
        if let timerConfiguration = timerConfiguration {
            return timerConfiguration.durations[currentWithinRound - 1]
        }
        return 0
    }
    private var phaseProgress: Double {
        if let phaseEndTime = phaseEndTime, let phaseStartTime = phaseStartTime {
            return Date().timeIntervalSince(phaseStartTime)/phaseEndTime.timeIntervalSince(phaseStartTime)
        }
        return 0
    }
    
    // Round info for phased sessions.
    @State private var currentWithinRound: Int = 1
    private var currentRound: Int {
        if let timerConfiguration = timerConfiguration {
            return Int(ceil(Double(currentWithinRound) / Double(timerConfiguration.roundLength)))
        }
        return -1
    }
    private var numberOfRounds: Int {
        if let timerConfiguration = timerConfiguration {
            return timerConfiguration.numberOfRounds
        }
        return -1
    }

    @State private var isShowingStatisticsSheet: Bool = false
    @State private var isShowingSettingsSheet: Bool = false
    @State private var isShowingConfigurationSheet: Bool = false
    
    @State private var waveOffset: CGFloat = K.initialOffset
    @State private var waveSpacing: CGFloat = K.initialSpacing
    
    var currentBreathStatus: BreathStatus {
        if isTimerRunning {
            switch timerMode {
            case .maxHold:
                    .hold
            default:
                timerConfiguration?.breathStatuses[currentWithinRound - 1] ?? .hold
            }
        } else {
            .rest
        }
    }
    
    var currentTime: TimeInterval {
        if timerMode == .maxHold {
            elapsedTime
        } else {
            phaseTimeRemaining
        }
    }
    
    func playSound(resource: String, type: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: type) else {
            print("Audio file not found.")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
    
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
    
    var countUp: Bool { timerMode == .maxHold }
    
    let defaultRadius: CGFloat = 1000
    let smallRadius: CGFloat = 400
    let largeRadius: CGFloat = 1200
    
    var body: some View {
        NavigationStack {
                    WaterView (
                        waveColors: K.colorThemes[colorThemeIndex].waveColors,
                        skyColors: K.colorThemes[colorThemeIndex].backgroundColors,
                        offset: waveOffset,
                        spacing: waveSpacing,
                        numberOfWaves: 4
                    ) {
                        VStack {
//                            if timerMode != .maxHold {
                            if false {
                                Text("ROUND \(currentRound) OF \(numberOfRounds)")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .foregroundStyle(accentColor)
//                                    .animation(.bouncy(duration: 0.8, extraBounce: 0.1), value: currentRound)
                            }
//                            Text("ROUND OF \(numberOfRounds)")
//                                .font(.system(.headline, design: .rounded, weight: .bold))
//                                .foregroundStyle(.white)
//                                .shadow(radius: 20)
                                AnimatedTime(time: currentTime, countUp: countUp)
                                    .font(thefont(size: 120))
                                    .foregroundStyle(
                                        .white.opacity(0.8)
                                        .shadow(
                                            .inner(
                                                color: .white.opacity(1),
                                                radius: 2, x: 0, y: 1
                                            )
                                        )
                                    )
                        }

                    } secondaryContent: {
                        HStack {
                            Text(currentBreathStatus.rawValue)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .blendMode(.screen)
                                .textCase(.uppercase)
                                .transition(.push(from: .trailing).combined(with: .blurReplace))
                                .id(currentBreathStatus)
                        }
                                .animation(.bouncy(duration: 0.8, extraBounce: 0.1), value: currentBreathStatus)
                    }
//                }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                        Button("Statistics", systemImage: "chart.xyaxis.line") {
                            isShowingStatisticsSheet = true
                        }
                        .disabled(isTimerRunning)
                    }
                    .matchedTransitionSource(id: "statisticsSheet", in: namespace)
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") {
                        isShowingSettingsSheet = true
                    }
                    .disabled(isTimerRunning)
                }
                .matchedTransitionSource(id: "settingsSheet", in: namespace)
                
                
                
//                if currentStatus == .started {
//                    ToolbarItem(placement: .bottomBar) {
//                        VStack(alignment: .leading) {
//                            if timerMode != .maxHold {
//                                Text("ROUND")
//                                    .font(.system(.caption, design: .rounded, weight: .regular))
//                                    .foregroundStyle(.white)
//                                Text("\(currentRound) / \(numberOfRounds)")
//                                    .font(.system(.title2, design: .rounded, weight: .heavy))
//                                    .foregroundStyle(accentColor.darker(by: -20))
//                                    .animation(.bouncy(duration: 0.8, extraBounce: 0.1), value: currentRound)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .animation(.bouncy(duration: 0.8, extraBounce: 0.1), value: currentBreathStatus)
//                    }
//                    .sharedBackgroundVisibility(.hidden)
//                }
                
//                ToolbarSpacer(.flexible, placement: .bottomBar)
                if isTimerRunning {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Reset", systemImage: "xmark", role: .destructive) {
                            stop()
                            reset()
                        }
                        .tint(.red)
                    }
                } else {
                    ToolbarItem(placement: .bottomBar) {
                        Menu(timerMode.rawValue, systemImage: getSymbolForMode(timerMode)) {
                            ForEach(TimerMode.allCases , id:\.self) { mode in
                                Button {
                                    timerMode = mode
                                    UserDefaults.standard.set(mode.rawValue, forKey: "lastUsedMode")
                                } label: {
                                    Label(mode.rawValue, systemImage: getSymbolForMode(mode))
                                    if [.co2Table, .o2Table].contains(mode) && maxHoldDuration < 1 {
                                        Text("Test your max hold first to unlock this mode.")
                                    }
                                }
                                .disabled([.co2Table, .o2Table].contains(mode) && maxHoldDuration < 1)
                                if mode == .boxBreathing {
                                    Divider()
                                }
                            }
                        }
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        if isTimerRunning {
                            stop()
                            save()
                        } else {
                            start()
                        }
                    } label: {
                        HStack {
                            if isTimerRunning {
                                Image(systemName: "stop.fill")
                                Text("STOP")
                            } else {
                                Image(systemName: "play.fill")
                                Text("START")
                            }
                        }
                        .fontWeight(.bold)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .padding(.horizontal)
                    }
                    .tint(accentColor)
                    .buttonStyle(.glassProminent)
                    .sensoryFeedback(trigger: isTimerRunning) { _, newValue in
                        if newValue {
                            return .start
                        } else {
                            return .stop
                        }
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                if isTimerRunning {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Audio", systemImage: "speaker.wave.2") {
                            
                        }
                    }
                }
                if !isTimerRunning && timerMode != .maxHold {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            isShowingConfigurationSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                    .matchedTransitionSource(id: "configurationSheet", in: namespace)
                }
            }
            .sheet(isPresented: $isShowingConfigurationSheet) {
                Group {
                    switch timerMode {
                    case .maxHold:
                        EmptyView()
                    case .boxBreathing:
                        BoxBreathingConfigurationView()
                            .presentationDetents([.fraction(0.7), .large])
                    case .co2Table:
                        CO2TableConfigurationView()
                    case .o2Table:
                        O2TableConfigurationView()
                    }
                }
                .navigationTransition(.zoom(sourceID: "configurationSheet", in: namespace))
            }
            .sheet(isPresented: $isShowingStatisticsSheet) {
                StatisticsView()
                    .navigationTransition(.zoom(sourceID: "statisticsSheet", in: namespace))
            }
            .sheet(isPresented: $isShowingSettingsSheet, content: {
                SettingsView(themeIndex: $colorThemeIndex)
                    .navigationTransition(.zoom(sourceID: "settingsSheet", in: namespace))
            })
            .tint(accentColor)
            .onAppear {
                prepareHaptics()
                if skipInitialRest && timerMode != .boxBreathing {
                    currentWithinRound = 2
                } else {
                    currentWithinRound = 1
                }
            }
            .onChange(of: timerMode) { _, newValue in
                if let timerConfiguration = timerConfiguration {
                    if skipInitialRest && timerMode != .boxBreathing {
                        currentWithinRound = 2
                    } else {
                        currentWithinRound = 1
                    }
                    phaseTimeRemaining = timerConfiguration.durations[currentWithinRound - 1]
                }
            }
            .onChange(of: currentTime) { _, _ in
                if currentBreathStatus == .hold {
                    Haptics.shared.play(.rigid)
                }
            }
            .onChange(of: currentBreathStatus) { _, newValue in
                
                var animationDuration: TimeInterval = 2
                
                if timerMode == .boxBreathing {
                    if let timerConfiguration = timerConfiguration {
                        animationDuration = timerConfiguration.durations[currentWithinRound - 1] + 1
                    }
                }
                
                withAnimation(.bouncy(duration: animationDuration, extraBounce: 0.05)) {
                    stopSound()
                    switch newValue {
                    case .inhale:
                        waveOffset = K.upperOffset
                        waveSpacing = K.upperSpacing
//                        isUnderwater = true
                    case .exhale:
                        waveOffset = K.lowerOffset
                        waveSpacing = K.lowerSpacing
//                        isUnderwater = false
                    case .hold:
                        if timerMode != .boxBreathing {
                            waveOffset = K.upperOffset
                            waveSpacing = K.upperSpacing
                            playSound(resource: "Underwater Water Ambience Water Bubbles Movement Peaceful 01", type: "wav")
//                            isUnderwater = true
                        }
                    case .breathe:
                        waveOffset = K.lowerOffset
                        waveSpacing = K.lowerSpacing
//                        isUnderwater = false
                    case .rest:
                        waveOffset = K.initialOffset
                        waveSpacing = K.initialSpacing
//                        isUnderwater = false
                    }
                }
                
                
                
                
                
                
                
//                if timerMode == .boxBreathing {
//                    if let timerConfiguration = timerConfiguration {
//                        withAnimation(.bouncy(
//                            duration: timerConfiguration.durations[currentWithinRound - 1],
//                            extraBounce: 0.05
//                        )) {
//                            if currentBreathStatus == .inhale {
//                                waveInitialOffset = -UIScreen.main.bounds.height*0.3
//                                waveMaxOffset = 20
//                            } else if currentBreathStatus == .exhale {
//                                waveInitialOffset = 50
//                                waveMaxOffset = 40
//                            }
//                        }
//                    }
//                } else {
//                    withAnimation(.bouncy(duration: 2, extraBounce: 0.05)) {
//                        if currentBreathStatus == .hold {
//                            waveInitialOffset = -UIScreen.main.bounds.height*0.3
//                            waveMaxOffset = 20
//                        } else {
//                            waveInitialOffset = 0
//                            waveMaxOffset = 40
//                        }
//                    }
//                }
            }
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was en error creating the engine:", error.localizedDescription)
        }
    }
    
    func breatheHaptics(duration: TimeInterval, increasing: Bool = true) {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        if engine == nil {
            prepareHaptics()
        }
        
        var events = [CHHapticEvent]()
        
        let pulsesPerSecond = 10
        let pulseCount = pulsesPerSecond * Int(duration)
        
        for i in 0..<pulseCount {

            let t = Float(i)/Float(pulseCount - 1)
            let bunchedPoint: Float = t * t
            
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: t)
            let relativeTime = duration * Double(bunchedPoint)
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: relativeTime
            )
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern:", error.localizedDescription)
        }
    }
    
    private func start() {
        isTimerRunning = true
        UIApplication.shared.isIdleTimerDisabled = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        })
        
        if timerMode != .maxHold {
            if skipInitialRest && timerMode != .boxBreathing {
                currentWithinRound = 2
            } else {
                currentWithinRound = 1
            }
            print(timerConfiguration!)
            nextPhase()
        }
    }
    
    
    private func stop() {
        isTimerRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
        startTime = nil
        timer?.invalidate()
        timer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
    }
    
    private func save() {
        
        // Save to database.
        let newEntry = Entry(duration: elapsedTime, mode: timerMode)
        modelContext.insert(newEntry)
        
        // Save to HealthKit.
        if syncToHealthKit && eligibleToSave() {
            healthKitManager.writeSample(
                from: Date(timeIntervalSinceNow: -elapsedTime),
                to: Date()
            )
        }
        
        // Update max hold duration.
        if timerMode == .maxHold {
            if elapsedTime > maxHoldDuration {
                maxHoldDuration = elapsedTime
                maxHoldDate = Date()
            }
        }
    }
    
    private func eligibleToSave() -> Bool {
        return timerMode == .maxHold && syncHoldToHK || [.boxBreathing].contains(timerMode) && syncBreathingToHK || [.co2Table, .o2Table].contains(timerMode) && syncTablesToHK
    }
    
    private func reset() {
        elapsedTime = 0
        if skipInitialRest && timerMode != .boxBreathing {
            currentWithinRound = 2
        } else {
            currentWithinRound = 1
        }
        
        if let timerConfiguration = timerConfiguration {
            phaseTimeRemaining = timerConfiguration.durations[currentWithinRound - 1]
        }
    }
    
    private func nextPhase() {
        phaseTimer?.invalidate()
        if let timerConfiguration = timerConfiguration {
            phaseTimeRemaining = timerConfiguration.durations[currentWithinRound - 1]
            phaseStartTime = Date()
            phaseEndTime = Date().addingTimeInterval(
                timerConfiguration.durations[currentWithinRound - 1]
            )
            
            if [.inhale, .exhale].contains(currentBreathStatus) {
                breatheHaptics(duration: timerConfiguration.durations[currentWithinRound - 1])
            }
            
            phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if phaseTimeRemaining > 1 {
                    phaseTimeRemaining -= 1
                } else {
                    if currentWithinRound == timerConfiguration.numberOfRounds * timerConfiguration.roundLength {
                        phaseTimeRemaining -= 1
                        stop()
                    } else {
                        currentWithinRound += 1
                        nextPhase()
                    }
                }
            }
        }
    }
}

class Haptics {
    static let shared = Haptics()
    
    private init() { }
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
    
}

struct AnimatedTime: View {
    
    var time: TimeInterval
    
    var countUp: Bool = false
    
    private var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = Int(time.rounded()) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
            HStack {
                ForEach(Array(formattedTime.enumerated()), id: \.offset) { index, char in
                    AnimatedDigit(digit: String(char), countUp: countUp)
                        .id("\(index)-\(char)")
                }
            }
            .animation(.bouncy(duration: 0.5, extraBounce: 0.2), value: formattedTime)
    }
}

struct AnimatedDigit: View {
    let digit: String
    var countUp: Bool = false
    
    var body: some View {
            Text(digit)
                .monospacedDigit()
                .transition(.push(from: countUp ? .bottom : .top).combined(with: .blurReplace))
    }
}

//func thefont(size: CGFloat = 180, weight: UIFont.Weight = .semibold, width: UIFont.Width = .compressed) -> Font {
//    let baseFont = UIFont.systemFont(ofSize: size, weight: weight, width: width)
//    let descriptor = CTFontDescriptorCreateCopyWithFeature(
//        baseFont.fontDescriptor,
//        kStylisticAlternativesType as CFNumber,
//        6 as CFNumber)
//    return Font(UIFont(descriptor: descriptor, size: 0.0))
//}

func thefont(size: CGFloat = 180, weight: UIFont.Weight = .semibold, width: UIFont.Width = .compressed) -> Font {
    let baseFont = UIFont.systemFont(ofSize: size, weight: weight, width: width)
    let descriptor = CTFontDescriptorCreateCopyWithFeature(
        baseFont.fontDescriptor,
        kStylisticAlternativesType as CFNumber,
        6 as CFNumber)
    return Font(UIFont(descriptor: descriptor, size: 0.0))
}

#Preview {
    @Previewable @State var colorThemeIndex = 0
    return TimerView(colorThemeIndex: $colorThemeIndex)
        .modelContainer(for: Entry.self, inMemory: true)
}
