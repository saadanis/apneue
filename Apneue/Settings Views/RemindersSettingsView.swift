//
//  RemindersSettingsView.swift
//  Apneue
//
//  Created by Saad Anis on 02/07/2025.
//

import SwiftUI
import UserNotifications

struct RemindersSettingsView: View {
    
    @Environment(\.editMode) private var editMode
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("enableReminders") var enableReminders: Bool = false
    
    // HHmm times joined by commas. Nil until the first import from an older version.
    @AppStorage("reminderTimes") var storedReminderTimes: String?
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var reminderTimes: [String] {
        get { storedReminderTimes?.split(separator: ",").map(String.init) ?? [] }
        nonmutating set { storedReminderTimes = newValue.sorted().joined(separator: ",") }
    }
    
    // The system keeps only 64 pending requests, and a reminder uses 7.
    let maxReminders = 64 / 7
    
    var hasRoomForReminder: Bool {
        reminderTimes.count < maxReminders
    }
    
    @State var isShowingCreateReminder: Bool = false
    
    @State var createNewReminderDate: Date = Date.now
    
    @State private var isShowingDeleteAllDialog = false
    
    // Nil until the first check ends. Until then, trust the saved choice, so the switch does not flash off.
    @State var authorizationStatus: UNAuthorizationStatus?
    
    var remindersOn: Bool {
        guard enableReminders else { return false }
        guard let authorizationStatus else { return true }
        return [.authorized, .provisional, .ephemeral].contains(authorizationStatus)
    }
    
    var isDuplicateReminder: Bool {
        reminderTimes.contains(reminderTime(for: createNewReminderDate))
    }
    
    let notificationMessages: [String] = [
        "Boost your lung capacity with today’s session.",
        "Take a deep breath—today’s session awaits.",
        "Time for today’s session.",
        "Session is ready—let’s go.",
        "Push further in today’s training.",
        "Today’s training is waiting.",
        "It’s time for your apnea session.",
        "Your next session starts now."
    ]
    
    @State var themeIndex: Int
    
    var body: some View {
        ThemedList(themeIndex: themeIndex) {
            if authorizationStatus == .denied {
                Section {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Notifications Are Disabled")
                            Text("Apneue cannot send reminders until you allow notifications in Settings.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bell.slash")
                    }
                    Link("Open Settings", destination: URL(string: UIApplication.openNotificationSettingsURLString)!)
                }
            }
            Section {
                Toggle("Enable Reminders", isOn: Binding {
                    remindersOn
                } set: { newValue in
                    // Set the choice now, so the switch does not spring back while the request runs.
                    enableReminders = newValue
                    Task { await setReminders(on: newValue) }
                })
                .disabled(authorizationStatus == .denied)
            }
            if remindersOn {
                Section {
                    if reminderTimes.isEmpty {
                        HStack {
                            Spacer()
                            Text("No reminders.")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                    ForEach(reminderTimes, id: \.self) { time in
                        HStack {
                            
                            let hour = Int(time.prefix(2)) ?? 0
                            let minute = Int(time.suffix(2)) ?? 0
                            let timeOfDay = getTimeOfDay(hour: hour)
                            
                            Label(timeOfDay.1, systemImage: timeOfDay.0)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(formattedTime(hour: hour, minute: minute))
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation {
                                    reminderTimes.removeAll { $0 == time }
                                    scheduleReminders()
                                }
                            }
                            .labelStyle(.iconOnly)
                            .tint(.red)
                        }
                    }
                    .onDelete(perform: deleteReminder)
                } header: {
                    Text("Scheduled Reminders")
                } footer: {
                    if !hasRoomForReminder {
                        Text("You have the maximum number of reminders.")
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .sheet(isPresented: $isShowingCreateReminder) {
            NavigationStack {
                ThemedList(themeIndex: themeIndex) {
                    DatePicker(selection: $createNewReminderDate, displayedComponents: .hourAndMinute) {}
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowInsets(.all, 0)
                        .listRowBackground(Color.clear)
                    VStack {
                        Text(isDuplicateReminder ? "You already have a reminder at this time." : "You will be reminded at this time every day.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .scrollDisabled(true)
                .navigationTitle("Create New Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", systemImage: "checkmark", role: .confirm) {
                            addReminder(date: createNewReminderDate)
                            isShowingCreateReminder = false
                        }
                        .disabled(isDuplicateReminder)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark", role: .cancel) {
                            isShowingCreateReminder = false
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.5)])
        }
        .toolbar {
            if remindersOn {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create New Reminder", systemImage: "plus", role: .confirm) {
                        createNewReminderDate = Date.now
                        isShowingCreateReminder = true
                    }
                    .disabled(!hasRoomForReminder || (editMode?.wrappedValue.isEditing == true))
                }
            }
            if editMode?.wrappedValue.isEditing == true {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Delete All") {
                        isShowingDeleteAllDialog = true
                    }
                    .confirmationDialog(
                        Text("Are you sure you want to delete all reminders?"),
                        isPresented: $isShowingDeleteAllDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Delete All", role: .destructive) {
                            deleteAllReminders()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing == true)
        .onChange(of: remindersOn) { _, isOn in
            if !isOn {
                editMode?.wrappedValue = .inactive
            }
        }
        .task(id: scenePhase) {
            if scenePhase == .active {
                await updateAuthorizationStatus()
                if storedReminderTimes == nil {
                    await importPendingReminders()
                }
            }
        }
    }
    
    func setReminders(on: Bool) async {
        if on {
            do {
                enableReminders = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            } catch {
                print(error.localizedDescription)
            }
            await updateAuthorizationStatus()
        } else {
            enableReminders = false
        }
        scheduleReminders()
    }
    
    func updateAuthorizationStatus() async {
        authorizationStatus = await notificationCenter.notificationSettings().authorizationStatus
    }
    
    // Older versions kept the times only in the pending requests, as the HHmm prefix of each identifier.
    func importPendingReminders() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        reminderTimes = Array(Set(requests.map { String($0.identifier.prefix(4)) }).sorted().prefix(maxReminders))
        scheduleReminders()
    }
    
    // Use UTC, because a local time can be missing on the day of a DST change.
    func formattedTime(hour: Int, minute: Int) -> String {
        Date(timeIntervalSinceReferenceDate: TimeInterval(hour * 3600 + minute * 60))
            .formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: .gmt))
    }
    
    func addReminder(date: Date) {
        reminderTimes.append(reminderTime(for: date))
        scheduleReminders()
    }
    
    func deleteReminder(at offsets: IndexSet) {
        reminderTimes.remove(atOffsets: offsets)
        scheduleReminders()
    }
    
    func deleteAllReminders() {
        reminderTimes = []
        scheduleReminders()
    }
    
    func getTimeOfDay(hour: Int) -> (String,String) {
        switch hour {
        case 5..<12:
            return ("sunrise", "Morning")
        case 12..<17:
            return ("sun.max", "Afternoon")
        case 17..<21:
            return ("sunset", "Evening")
        default:
            return ("moon.stars", "Night")
        }
    }
    
    func reminderTime(for date: Date) -> String {
        let calendar = Calendar.current
        return String(format: "%02d%02d", calendar.component(.hour, from: date), calendar.component(.minute, from: date))
    }
    
    // Rebuild all pending requests from the saved times, so the two never differ.
    func scheduleReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
        guard enableReminders else { return }
        
        for time in reminderTimes {
            let messages = notificationMessages.shuffled()
            
            // A repeating request cannot change its message, so use one request for each weekday.
            for weekday in 1...7 {
                
                // Configuring the content.
                let content = UNMutableNotificationContent()
                content.title = "Time to Train"
                content.body = messages[weekday - 1]
                content.sound = UNNotificationSound.default
                
                // Configuring a recurring date-based trigger.
                let dateComponents = DateComponents(hour: Int(time.prefix(2)), minute: Int(time.suffix(2)), weekday: weekday)
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: true
                )
                
                // Registering a notification request.
                let request = UNNotificationRequest(identifier: "\(time)-\(weekday)", content: content, trigger: trigger)
                
                notificationCenter.add(request)
            }
        }
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

#Preview {
    NavigationStack {
        RemindersSettingsView(themeIndex: 0)
    }
}
