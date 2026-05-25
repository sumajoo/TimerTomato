//
//  PomodoroCompletionFeedback.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroCompletionFeedback: Equatable {
    enum Kind: Equatable {
        case focusWin
        case momentum
        case blocked
    }

    let kind: Kind
    let title: String
    let detail: String
    let offersRescueAction: Bool
}
