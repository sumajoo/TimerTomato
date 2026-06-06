//
//  PreviewPomodoroNotifier.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

#if DEBUG
@MainActor
final class PreviewPomodoroNotifier: PomodoroNotifying {
    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void) {}

    func authorizationStatus() async -> PomodoroNotificationPermission {
        .available
    }

    func requestAuthorizationIfNeeded() async -> PomodoroNotificationPermission {
        .available
    }

    func notifySessionCompleted(plannedMinutes: Int) async {}

    func notifyBreakCompleted(plannedMinutes: Int) async {}

    func scheduleChecklistReminder(_ reminder: PomodoroChecklistReminder) async {}

    func cancelChecklistReminders(identifiers: [String]) {}
}
#endif
