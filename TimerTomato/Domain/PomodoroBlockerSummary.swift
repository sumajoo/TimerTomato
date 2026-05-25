//
//  PomodoroBlockerSummary.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroBlockerSummary: Equatable {
    let blockedCount: Int
    let mostCommonReason: PomodoroBlockerReason?
    let nextSteps: [String]

    var hasBlockers: Bool {
        blockedCount > 0
    }
}
