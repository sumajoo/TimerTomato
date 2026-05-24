//
//  UserNotificationScheduler.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
import UserNotifications

@MainActor
final class UserNotificationScheduler: PomodoroNotifying {
    private var hasRequestedAuthorization = false

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
}
