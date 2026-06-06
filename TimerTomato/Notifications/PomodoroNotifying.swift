//
//  PomodoroNotifying.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

@MainActor
protocol PomodoroNotifying: AnyObject {
    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void)
    func authorizationStatus() async -> PomodoroNotificationPermission
    func requestAuthorizationIfNeeded() async -> PomodoroNotificationPermission
    func notifySessionCompleted(plannedMinutes: Int) async
    func notifyBreakCompleted(plannedMinutes: Int) async
    func scheduleChecklistReminder(_ reminder: PomodoroChecklistReminder) async
    func cancelChecklistReminders(identifiers: [String])
}

enum PomodoroNotificationPermission: Equatable {
    case unknown
    case available
    case denied
}

struct PomodoroChecklistReminder: Equatable {
    let identifier: String
    let title: String
    let delaySeconds: TimeInterval

    init(identifier: String, title: String, delaySeconds: TimeInterval) {
        self.identifier = identifier
        self.title = PomodoroChecklistItem.normalizedTitle(title)
        self.delaySeconds = max(1, delaySeconds)
    }
}
