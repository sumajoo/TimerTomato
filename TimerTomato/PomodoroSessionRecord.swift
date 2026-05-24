//
//  PomodoroSessionRecord.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
import SwiftData

@Model
final class PomodoroSessionRecord {
    #Index<PomodoroSessionRecord>([\.startedAt])

    var id: UUID
    var startedAt: Date
    var endedAt: Date
    var plannedMinutes: Int
    var pauseBeforeSeconds: TimeInterval?

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        plannedMinutes: Int,
        pauseBeforeSeconds: TimeInterval?
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.pauseBeforeSeconds = pauseBeforeSeconds
    }

    convenience init(session: PomodoroSession) {
        self.init(
            id: session.id,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            plannedMinutes: session.plannedMinutes,
            pauseBeforeSeconds: session.pauseBeforeSeconds
        )
    }
}

extension PomodoroSession {
    init(record: PomodoroSessionRecord) {
        self.init(
            id: record.id,
            startedAt: record.startedAt,
            endedAt: record.endedAt,
            plannedMinutes: record.plannedMinutes,
            pauseBeforeSeconds: record.pauseBeforeSeconds
        )
    }
}
