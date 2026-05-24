//
//  PomodoroWeekSummary.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroWeekSummary: Equatable {
    let startDate: Date
    let days: [PomodoroHistoryDay]
    let weeklyGoalSessions: Int

    var sessionCount: Int {
        days.reduce(0) { result, day in
            result + day.sessionCount
        }
    }

    var focusMinutes: Int {
        days.reduce(0) { result, day in
            result + day.focusMinutes
        }
    }

    var goalProgress: Double {
        guard weeklyGoalSessions > 0 else {
            return 0
        }

        return min(Double(sessionCount) / Double(weeklyGoalSessions), 1)
    }

    var didReachGoal: Bool {
        sessionCount >= weeklyGoalSessions
    }

    var goalCountText: String {
        "\(min(sessionCount, weeklyGoalSessions))/\(weeklyGoalSessions)"
    }
}
