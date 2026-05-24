//
//  PomodoroNotificationAction.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

enum PomodoroNotificationAction: String {
    static let categoryIdentifier = "TimerTomato.SessionCompleted"
    static let breakCategoryIdentifier = "TimerTomato.BreakCompleted"

    case startBreak = "TimerTomato.Action.StartBreak"
    case startNextFocus = "TimerTomato.Action.StartNextFocus"
    case done = "TimerTomato.Action.Done"
}
