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

    private var actionHandler: (@MainActor (PomodoroNotificationAction) -> Void)?

    override init() {
        super.init()

        configureNotificationCategories()
        UNUserNotificationCenter.current().delegate = self
    }

    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void) {
        actionHandler = handler
    }

    func requestAuthorizationIfNeeded() async {
        guard !hasRequestedAuthorization else {
            return
        }

        hasRequestedAuthorization = true

        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            // Timer completion still works when notification permission is unavailable.
        }
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
