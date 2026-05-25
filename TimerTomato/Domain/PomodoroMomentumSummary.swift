//
//  PomodoroMomentumSummary.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroMomentumSummary: Equatable {
    let days: [PomodoroMomentumDay]

    var activeDayCount: Int {
        days.filter(\.hasActivity).count
    }

    var hasActivityToday: Bool {
        days.last?.hasActivity == true
    }

    var countText: String {
        "\(activeDayCount)/\(days.count)"
    }
}

struct PomodoroMomentumDay: Identifiable, Equatable {
    let date: Date
    let hasActivity: Bool

    var id: Date {
        date
    }
}
