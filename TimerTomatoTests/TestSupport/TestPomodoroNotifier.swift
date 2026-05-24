//
//  TestPomodoroNotifier.swift
//  TimerTomatoTests
//
//  Created by Jonas Becker on 24.05.26.
//

@testable import TimerTomato

@MainActor
final class TestPomodoroNotifier: PomodoroNotifying {
    private(set) var authorizationRequestCount = 0
    private(set) var completedSessionMinutes: [Int] = []
    private(set) var completedBreakMinutes: [Int] = []
    private var actionHandler: (@MainActor (PomodoroNotificationAction) -> Void)?

    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void) {
        actionHandler = handler
    }

    func requestAuthorizationIfNeeded() async {
        authorizationRequestCount += 1
    }

    func notifySessionCompleted(plannedMinutes: Int) async {
        completedSessionMinutes.append(plannedMinutes)
    }

    func notifyBreakCompleted(plannedMinutes: Int) async {
        completedBreakMinutes.append(plannedMinutes)
    }

    func perform(action: PomodoroNotificationAction) {
        actionHandler?(action)
    }
}
