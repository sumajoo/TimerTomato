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

    func requestAuthorizationIfNeeded() async {
        authorizationRequestCount += 1
    }

    func notifySessionCompleted(plannedMinutes: Int) async {
        completedSessionMinutes.append(plannedMinutes)
    }
}
