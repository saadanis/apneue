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
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    @State var scheduledNotifications: [UNNotificationRequest] = []
    
    @State var isShowingCreateReminder: Bool = false
    
    @State var createNewReminderDate: Date = Date.now
    
    @State private var isShowingDeleteAllDialog = false
    
    @State var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    @State var isConfirmationDialogPresented: Bool = false
    
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
            Section {
                HStack {
                    Text("Authorization Status")
                    Spacer()
                    HStack {
                        switch authorizationStatus {
                        case .notDetermined:
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.secondary)
                        case .denied:
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        case .authorized, .provisional, .ephemeral:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        @unknown default:
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        Group {
                            switch authorizationStatus {
                            case .notDetermined:
                                Text("Not Determined")
                            case .denied:
                                Text("Denied")
                            case .authorized, .provisional, .ephemeral:
                                Text("Authorized")
                            @unknown default:
                                Text("Unknown")
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 6)
                    .padding(.leading, 8)
                    .padding(.trailing, 10)
                    .background {
                        switch authorizationStatus {
                        case .notDetermined:
                            Color.secondary.opacity(0.4)
                        case .denied:
                            Color.red.opacity(0.4)
                        case .authorized, .provisional, .ephemeral:
                            Color.green.opacity(0.4)
                        @unknown default:
                            Color.gray.opacity(0.4)
                        }
                    }
                    .clipShape(.capsule)
                }
                Toggle("Enable Reminders", isOn: $enableReminders)
                    .onChange(of: enableReminders) { _, newValue in
                        if newValue {
                            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if let error {
                                    print(error.localizedDescription)
                                }
                            }
                        } else {
                            isConfirmationDialogPresented = true
                        }
                        updateAuthorizationStatus()
                    }
                    .alert("Disable Reminders?", isPresented: $isConfirmationDialogPresented) {
                        Button("Disable", role: .destructive) {
                            deleteAllReminders()
                        }
                        Button("Cancel", role: .cancel) {
                            enableReminders = true
                        }
                    } message: {
                        Text("Disabling reminders will delete all existing reminders. Continue?")
                    }
                

            }
            Section("Scheduled Reminders") {
                if scheduledNotifications.isEmpty {
                    HStack {
                        Spacer()
                        Text("No reminders.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Spacer()
                    }
                }
                ForEach(scheduledNotifications.sorted(by: { $0.identifier < $1.identifier }), id: \.identifier) { notification in
                    HStack {
                        
                        let notificationDate = formatIdentifierToDate(
                            identifier: notification.identifier)
                        let timeOfDay = getTimeOfDay(date: notificationDate)
                        
                        Label(timeOfDay.1, systemImage: timeOfDay.0)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(
                            notificationDate.formatted(
                                date: .omitted,
                                time: .shortened
                            )
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deleteReminder)
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
                        Text("You will be reminded at this time every day.")
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
                            Task {
                                _ = await createReminder(date: createNewReminderDate)
                                isShowingCreateReminder = false
                            }
                        }
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
            ToolbarItem {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create New Reminder", systemImage: "plus", role: .confirm) {
                    isShowingCreateReminder = true
                }
                .disabled(!enableReminders || (editMode?.wrappedValue.isEditing == true))
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
        .onAppear {
            loadNotifications()
            updateAuthorizationStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                loadNotifications()
                updateAuthorizationStatus()
            }
        }
    }
    
    func updateAuthorizationStatus() {
        notificationCenter.getNotificationSettings { settings in
            authorizationStatus = settings.authorizationStatus
        }
    }
    
    func formatIdentifierToDate(identifier: String) -> Date {
        
        let hour = Int(identifier.prefix(2)) ?? 0
        let minute = Int(identifier.suffix(2)) ?? 0
        let calendar = Calendar.current
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
    
    func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            let identifier = scheduledNotifications[index].identifier
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            }
        scheduledNotifications.remove(atOffsets: offsets)
    }
    
    func deleteAllReminders() {
        let identifiers = scheduledNotifications.map(\.identifier)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        scheduledNotifications.removeAll()
    }
    
    func loadNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            scheduledNotifications = requests
        }
    }
    
    func getTimeOfDay(date: Date) -> (String,String) {
        let hour = Calendar.current.component(.hour, from: date)
        
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
    
    func createReminder(date: Date) async -> Bool {
        
        let calendar = Calendar.current
        let hour = String(format: "%02d", calendar.component(.hour, from: date))
        let minute = String(format: "%02d", calendar.component(.minute, from: date))
        let identifier = "\(hour)\(minute)"
        
        let requests = await notificationCenter.pendingNotificationRequests()
        
        for request in requests {
            if request.identifier == identifier {
                return false
            }
        }
        
        // Configuring the content.
        let content = UNMutableNotificationContent()
        content.title = "Time to Train"
        content.body = notificationMessages.randomElement() ?? "No message set."
        content.sound = UNNotificationSound.default
        
        // Configuring a recurring date-based trigger.
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // Registering a notification request.
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            scheduledNotifications = await notificationCenter.pendingNotificationRequests()
            return true
        } catch {
            print(error)
        }
        return false
    }
}

#Preview {
    NavigationStack {
        RemindersSettingsView(themeIndex: 0)
    }
}
