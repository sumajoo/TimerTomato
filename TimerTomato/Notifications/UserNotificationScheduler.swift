//
//  UserNotificationScheduler.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
import UserNotifications

@MainActor
final class UserNotificationScheduler: NSObject, PomodoroNotifying, UNUserNotificationCenterDelegate {
    private var hasRequestedAuthorization = false
    private var cachedPermission = PomodoroNotificationPermission.unknown

    private var actionHandler: (@MainActor (PomodoroNotificationAction) -> Void)?

    override init() {
        super.init()

        configureNotificationCategories()
        UNUserNotificationCenter.current().delegate = self
    }

    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void) {
        actionHandler = handler
    }

    func authorizationStatus() async -> PomodoroNotificationPermission {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        cachedPermission = PomodoroNotificationPermission(status: settings.authorizationStatus)
        return cachedPermission
    }

    func requestAuthorizationIfNeeded() async -> PomodoroNotificationPermission {
        let currentPermission = await authorizationStatus()

        guard currentPermission == .unknown, !hasRequestedAuthorization else {
            return currentPermission
        }

        do {
            hasRequestedAuthorization = true
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            cachedPermission = granted ? .available : .denied
        } catch {
            // Timer completion still works when notification permission is unavailable.
            hasRequestedAuthorization = false
            cachedPermission = await authorizationStatus()
        }

        return cachedPermission
    }

    func notifySessionCompleted(plannedMinutes: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro abgeschlossen"
        content.body = "\(plannedMinutes) Minuten Fokus sind geschafft."
        content.sound = .default
        content.categoryIdentifier = PomodoroNotificationAction.categoryIdentifier

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // A failed notification must not affect session recording.
        }
    }

    func notifyBreakCompleted(plannedMinutes: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Pause beendet"
        content.body = "\(plannedMinutes) Minuten Pause sind vorbei."
        content.sound = .default
        content.categoryIdentifier = PomodoroNotificationAction.breakCategoryIdentifier

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // A failed notification must not affect timer state.
        }
    }

    func scheduleChecklistReminder(_ reminder: PomodoroChecklistReminder) async {
        let content = UNMutableNotificationContent()
        content.title = "Jetzt"
        content.body = reminder.title
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: reminder.delaySeconds,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: reminder.identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // Checklist reminders are assistive; timer state must remain independent.
        }
    }

    func cancelChecklistReminders(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier

        Task { @MainActor in
            handleAction(identifier: actionIdentifier)
        }

        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    private func configureNotificationCategories() {
        let startBreak = UNNotificationAction(
            identifier: PomodoroNotificationAction.startBreak.rawValue,
            title: "Pause starten",
            options: []
        )
        let startNextFocus = UNNotificationAction(
            identifier: PomodoroNotificationAction.startNextFocus.rawValue,
            title: "Nächsten Fokus starten",
            options: [.foreground]
        )
        let done = UNNotificationAction(
            identifier: PomodoroNotificationAction.done.rawValue,
            title: "Fertig",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: PomodoroNotificationAction.categoryIdentifier,
            actions: [startBreak, startNextFocus, done],
            intentIdentifiers: [],
            options: []
        )
        let breakCategory = UNNotificationCategory(
            identifier: PomodoroNotificationAction.breakCategoryIdentifier,
            actions: [startNextFocus, done],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category, breakCategory])
    }

    private func handleAction(identifier: String) {
        guard let action = PomodoroNotificationAction(rawValue: identifier) else {
            return
        }

        actionHandler?(action)
    }
}

private extension PomodoroNotificationPermission {
    init(status: UNAuthorizationStatus) {
        switch status {
        case .authorized, .provisional, .ephemeral:
            self = .available
        case .denied:
            self = .denied
        case .notDetermined:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }
}
