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

    func requestAuthorizationIfNeeded() async {}

    func notifySessionCompleted(plannedMinutes: Int) async {}

    func notifyBreakCompleted(plannedMinutes: Int) async {}
}
#endif
