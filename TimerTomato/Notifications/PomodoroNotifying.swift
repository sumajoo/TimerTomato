//
//  PomodoroNotifying.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

@MainActor
protocol PomodoroNotifying: AnyObject {
    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void)
    func authorizationStatus() async -> PomodoroNotificationPermission
    func requestAuthorizationIfNeeded() async -> PomodoroNotificationPermission
    func notifySessionCompleted(plannedMinutes: Int) async
    func notifyBreakCompleted(plannedMinutes: Int) async
}

enum PomodoroNotificationPermission: Equatable {
    case unknown
    case available
    case denied
}
