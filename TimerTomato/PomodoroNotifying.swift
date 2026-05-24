//
//  PomodoroNotifying.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

@MainActor
protocol PomodoroNotifying: AnyObject {
    func requestAuthorizationIfNeeded() async
    func notifySessionCompleted(plannedMinutes: Int) async
}
