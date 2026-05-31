//
//  PomodoroFocusSegment.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import Foundation

struct PomodoroFocusSegment: Identifiable, Codable, Equatable {
    let id: UUID
    let intent: String?
    let startedFocusSeconds: TimeInterval
    let focusSeconds: TimeInterval

    nonisolated init(
        id: UUID = UUID(),
        intent: String?,
        startedFocusSeconds: TimeInterval,
        focusSeconds: TimeInterval
    ) {
        self.id = id
        self.intent = PomodoroSession.normalizedIntent(intent)
        self.startedFocusSeconds = max(0, startedFocusSeconds)
        self.focusSeconds = max(0, focusSeconds)
    }
}
