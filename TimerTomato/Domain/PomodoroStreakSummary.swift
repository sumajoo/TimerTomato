//
//  PomodoroStreakSummary.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroStreakSummary: Equatable {
    let currentDays: Int
    let bestDays: Int
    let latestGoalDate: Date?

    var currentText: String {
        Self.dayText(currentDays)
    }

    var bestText: String {
        Self.dayText(bestDays)
    }

    private static func dayText(_ days: Int) -> String {
        days == 1 ? "1 Tag" : "\(days) Tage"
    }
}
