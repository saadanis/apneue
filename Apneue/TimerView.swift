//
//  TimerView.swift
//  Apneue
//
//  Created by Saad Anis on 30/05/2025.
//

import SwiftUI
import SwiftData
import CoreHaptics

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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
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
    
    @Namespace private var namespace
    
    @StateObject var healthKitManager = HealthKitManager.shared
    
    @AppStorage("syncToHealthKit") var syncToHealthKit: Bool = false
    @AppStorage("syncHoldToHK") var syncHoldToHK: Bool = false
    @AppStorage("syncBreathingToHK") var syncBreathingToHK: Bool = false
    @AppStorage("syncTablesToHK") var syncTablesToHK: Bool = false
    
    // Setup options.
    
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
    
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false
    
    
    // Color palette options.
    @Binding var colorThemeIndex: Int
    
    var accentColor: Color {
        K.colorThemes[colorThemeIndex].accentColor
    }
    
    @State private var skipInitialRest: Bool = (UserDefaults.standard.object(forKey: "skipInitialRest") as? Bool) ?? true
    
    @State private var hapticsEnabled: Bool = (UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool) ?? true
    
    @State private var timerMode: TimerMode = TimerMode(
        rawValue: UserDefaults.standard.string(
            forKey: "defaultTimerMode"
        ) ?? ""
    ) ?? TimerMode(
        rawValue: UserDefaults.standard.string(
            forKey: "lastUsedMode"
        ) ?? ""
    ) ?? .boxBreathing
    
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
    @State private var isShowingOnboardingSheet: Bool = false
    @State private var isShowingDiscardDialog: Bool = false
    
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
    
    var countUp: Bool { timerMode == .maxHold }

    private var subtitle: String {
        switch timerMode {
        case .maxHold:
            return "Personal Best \(maxHoldDuration.formattedTime)"
        case .boxBreathing:
            let duration = Int(boxBreathingDuration)
            return "\(duration)→\(duration)→\(duration)→\(duration) (×\(boxBreathingNumberOfRounds))"
        case .co2Table:
            let initialRest = co2RestStartingDuration.formattedTime
            let lastRest = co2RestEndingDuration.formattedTime
            let hold = (co2HoldPercentage * maxHoldDuration).formattedTime
            return "\(initialRest)→\(lastRest) & \(hold)"
        case .o2Table:
            let rest = o2RestDuration.formattedTime
            let initialHold = (Double(maxHoldDuration)*o2HoldStartingPercentage).formattedTime
            let finalHold = (Double(maxHoldDuration)*o2HoldEndingPercentage).formattedTime
            return "\(rest) & \(initialHold)→\(finalHold)"
        }
    }

    var body: some View {
        // Read once per body pass: both rebuild `timerConfiguration`, and WaterView's
        // TimelineView calls secondaryContent three times per frame.
        let roundText = timerMode == .maxHold ? " " : "ROUND \(currentRound) OF \(numberOfRounds)"
        let breathStatus = currentBreathStatus

        Color.clear
        .background {
            WaterView (
                waveColors: K.colorThemes[colorThemeIndex].waveColors,
                skyColors: K.colorThemes[colorThemeIndex].backgroundColors(for: colorScheme),
                offset: waveOffset,
                spacing: waveSpacing,
                numberOfWaves: 4
            ) {
                VStack {
                    AnimatedTime(time: currentTime, countUp: countUp)
                        .font(.system(size: 120, weight: .semibold, design: .default))
                        .fontDesign(.default)
                        .fontWeight(.semibold)
                        .fontWidth(.compressed)
                        .foregroundStyle(.white)
                }
                
            } secondaryContent: { maskValue in
                
                var foregroundColor: Color {
                    if colorScheme == .dark {
                        return .white
                    }
                    if maskValue == 0 {
                        return K.colorThemes[colorThemeIndex].accentColor
                    }
                    return .white
                }
                
                VStack(spacing: 100) {
                    HStack {
                        Text(roundText)
                            .fontWeight(.bold)
                            .foregroundStyle(foregroundColor)
                            .blendMode(
                                colorScheme == .dark ?
                                    .lighten :
                                        .lighten
                            )
//                            .foregroundStyle(
//                                colorScheme == .dark ? Color.black : Color.black
//                            )
                    }
                    .frame(height: 50)
                    HStack {
                        Text(breathStatus.rawValue)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .textCase(.uppercase)
                            .transition(.push(from: .trailing).combined(with: .blurReplace))
                            .id(breathStatus)
                    }
                    .frame(height: 60)
                    .animation(.bouncy(duration: 0.8, extraBounce: 0.1), value: breathStatus)
                }
            }
        }
        .navigationTitle(timerMode.rawValue)
        .navigationSubtitle(subtitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isTimerRunning {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingStatisticsSheet = true
                    } label: {
                        Label("Statistics", systemImage: "chart.xyaxis.line")
                            .matchedTransitionSource(id: "statisticsSheet", in: namespace)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                            .matchedTransitionSource(id: "settingsSheet", in: namespace)
                    }
                }
            }

            ToolbarItem(placement: .bottomBar) {
                if isTimerRunning {
                    Button {
                        isShowingDiscardDialog = true
                    } label: {
                        Label("Discard", systemImage: "trash")
                            .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                    }
                    .tint(.white)
                    // Kept on the button itself so the dialog morphs out of it.
                    .confirmationDialog(
                        "Discard this session?",
                        isPresented: $isShowingDiscardDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Discard", role: .destructive) {
                            stop()
                            reset()
                        }
                    }
                } else {
                    Menu {
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
                    } label: {
                        Label(timerMode.rawValue, systemImage: getSymbolForMode(timerMode))
                            .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                    }
                    .tint(.white)
                }
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button {
                    if isTimerRunning {
                        stop()
                        save()
                        reset()
                    } else {
                        start()
                    }
                } label: {
                    Label(
                        isTimerRunning ? "Stop" : "Start",
                        systemImage: isTimerRunning ? "stop.fill" : "play.fill"
                    )
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                }
                .buttonStyle(.glassProminent)
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button {
                    if isTimerRunning {
                        hapticsEnabled.toggle()
                    } else {
                        isShowingConfigurationSheet = true
                    }
                } label: {
                    let (title, symbol) = isTimerRunning
                    ? (hapticsEnabled ? ("Haptics On", "waveform") : ("Haptics Off", "waveform.slash"))
                    : (timerMode == .maxHold ? ("Safety", "exclamationmark.shield") : ("Configure", "slider.horizontal.3"))
                    Label(title, systemImage: symbol)
                        .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                        .matchedTransitionSource(id: "configurationSheet", in: namespace)
                }
                .tint(.white)
            }
        }
        .sheet(
            isPresented: $isShowingOnboardingSheet,
            onDismiss: {
                onboardingComplete = true
            }
        ) {
            OnboardingView(themeIndex: colorThemeIndex)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $isShowingConfigurationSheet) {
            Group {
                switch timerMode {
                case .maxHold:
                    NavigationStack {
                        SafetyView(themeIndex: colorThemeIndex)
                    }
                    .presentationDetents([.fraction(0.7)])
                case .boxBreathing:
                    BoxBreathingConfigurationView(themeIndex: colorThemeIndex)
                        .presentationDetents([.fraction(0.7), .large])
                case .co2Table:
                    CO2TableConfigurationView(themeIndex: colorThemeIndex)
                case .o2Table:
                    O2TableConfigurationView(themeIndex: colorThemeIndex)
                }
            }
            .navigationTransition(.zoom(sourceID: "configurationSheet", in: namespace))
        }
        .sheet(isPresented: $isShowingStatisticsSheet) {
            StatisticsView()
                .navigationTransition(.zoom(sourceID: "statisticsSheet", in: namespace))
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $isShowingSettingsSheet, content: {
            SettingsView()
                .navigationTransition(.zoom(sourceID: "settingsSheet", in: namespace))
                .interactiveDismissDisabled()
        })
        .onAppear {
            
            if !onboardingComplete {
                isShowingOnboardingSheet = true
            }
            
            Haptics.shared.prepareIfNeeded()
            Haptics.shared.isEnabled = hapticsEnabled

            if skipInitialRest && timerMode != .boxBreathing {
                currentWithinRound = 2
            } else {
                currentWithinRound = 1
            }
        }
        .onChange(of: hapticsEnabled) { _, newValue in
            Haptics.shared.isEnabled = newValue
            UserDefaults.standard.set(newValue, forKey: "hapticsEnabled")
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
        .onChange(of: breathStatus) { _, newValue in
            
            var animationDuration: TimeInterval = 2
            
            if timerMode == .boxBreathing {
                if let timerConfiguration = timerConfiguration {
                    animationDuration = timerConfiguration.durations[currentWithinRound - 1] + 1
                }
            }
            
            withAnimation(.bouncy(duration: animationDuration, extraBounce: 0.05)) {
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
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Haptics.shared.prepareIfNeeded()
            }
        }
    }
    
    private func start() {
        withAnimation {
            isTimerRunning = true
        }
        UIApplication.shared.isIdleTimerDisabled = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        })
        
        if timerMode != .maxHold {
            guard let timerConfiguration = timerConfiguration else { return }
            if skipInitialRest && timerMode != .boxBreathing {
                currentWithinRound = 2
            } else {
                currentWithinRound = 1
            }
            phaseTimeRemaining = timerConfiguration.durations[currentWithinRound - 1]
            nextPhase()
        }
    }
    
    
    private func stop() {
        // The dialog is hosted by the Discard button, which this call removes; clear the flag
        // here so a session ending on its own can't strand it.
        isShowingDiscardDialog = false
        withAnimation {
            isTimerRunning = false
        }
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
                Haptics.shared.breathe(duration: timerConfiguration.durations[currentWithinRound - 1])
            }
            
            phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if phaseTimeRemaining > 1 {
                    phaseTimeRemaining -= 1
                } else {
                    if currentWithinRound == timerConfiguration.numberOfRounds * timerConfiguration.roundLength {
                        phaseTimeRemaining -= 1
                        stop()
                        save()
                        Haptics.shared.notify(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            reset()
                        }
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
    
    var isEnabled = true
    private var engine: CHHapticEngine?
    
    private init() { }
    
    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            
            engine?.resetHandler = { [weak self] in
                self?.engine = nil
            }
            
            engine?.stoppedHandler = { [weak self] reason in
                print(reason)
                self?.engine = nil
            }
            
            try engine?.start()
        } catch {
            print("There was an error creating the engine:", error.localizedDescription)
        }
    }
    
    func prepareIfNeeded() {
        guard isEnabled else { return }
        if engine == nil {
            prepareEngine()
        }
    }
    
    func breathe(duration: TimeInterval, increasing: Bool = true) {
        guard isEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        if engine == nil {
            prepareEngine()
        }
        
        do {
            try engine?.start()
        } catch {
            print("Failed to start engine:", error.localizedDescription)
        }
        
        var events = [CHHapticEvent]()
        let pulsesPerSecond = 10
        let pulseCount = pulsesPerSecond * Int(duration)
        
        for i in 0..<pulseCount {
            let t = Float(i) / Float(max(pulseCount - 1, 1))
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
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
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
                    .offset(y: char == ":" ? -10 : 0)
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

#Preview {
    @Previewable @State var colorThemeIndex = 0
    return NavigationStack {
        TimerView(colorThemeIndex: $colorThemeIndex)
    }
    .modelContainer(for: Entry.self, inMemory: true)
}
