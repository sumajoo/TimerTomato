//
//  PomodoroNotifying.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

@MainActor
protocol PomodoroNotifying: AnyObject {
    func configureActionHandler(_ handler: @escaping @MainActor (PomodoroNotificationAction) -> Void)
    func requestAuthorizationIfNeeded() async
    func notifySessionCompleted(plannedMinutes: Int) async
    func notifyBreakCompleted(plannedMinutes: Int) async
}
