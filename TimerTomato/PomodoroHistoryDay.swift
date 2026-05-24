//
//  PomodoroHistoryDay.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroHistoryDay: Identifiable, Equatable {
    let date: Date
    let sessions: [PomodoroSession]
    let dailyGoalSessions: Int

    var id: Date {
        date
    }

    var sessionCount: Int {
        sessions.count
    }

    var focusMinutes: Int {
        sessions.reduce(0) { result, session in
            result + session.plannedMinutes
        }
    }

    var goalProgress: Double {
        guard dailyGoalSessions > 0 else {
            return 0
        }

        return min(Double(sessionCount) / Double(dailyGoalSessions), 1)
    }

    var didReachGoal: Bool {
        sessionCount >= dailyGoalSessions
    }
}
