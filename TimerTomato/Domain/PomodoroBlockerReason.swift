//
//  PomodoroBlockerReason.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

enum PomodoroBlockerReason: String, Codable, CaseIterable, Equatable {
    case unclearNextStep
    case tooLarge
    case waiting
    case distraction
    case other

    var title: String {
        switch self {
        case .unclearNextStep:
            "Unklarer nächster Schritt"
        case .tooLarge:
            "Zu groß"
        case .waiting:
            "Warten"
        case .distraction:
            "Ablenkung"
        case .other:
            "Sonstiges"
        }
    }

    var shortTitle: String {
        switch self {
        case .unclearNextStep:
            "Nächster Schritt"
        case .tooLarge:
            "Zu groß"
        case .waiting:
            "Warten"
        case .distraction:
            "Ablenkung"
        case .other:
            "Sonstiges"
        }
    }

    var systemImage: String {
        switch self {
        case .unclearNextStep:
            "questionmark.circle.fill"
        case .tooLarge:
            "arrow.down.right.and.arrow.up.left.circle.fill"
        case .waiting:
            "clock.fill"
        case .distraction:
            "bell.fill"
        case .other:
            "ellipsis.circle.fill"
        }
    }
}
