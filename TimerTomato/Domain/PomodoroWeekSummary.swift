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

    var focusWinCount: Int {
        days.reduce(0) { result, day in
            result + day.focusWinCount
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

        return min(Double(focusWinCount) / Double(weeklyGoalSessions), 1)
    }

    var didReachGoal: Bool {
        focusWinCount >= weeklyGoalSessions
    }

    var remainingFocusWins: Int {
        max(weeklyGoalSessions - focusWinCount, 0)
    }

    var goalCountText: String {
        "\(min(focusWinCount, weeklyGoalSessions))/\(weeklyGoalSessions)"
    }
}
