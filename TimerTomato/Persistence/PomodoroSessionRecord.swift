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

    var id = UUID()
    var startedAt = Date.distantPast
    var endedAt = Date.distantPast
    var plannedMinutes = 0
    var pauseBeforeSeconds: TimeInterval?
    var intent: String?
    var outcomeRawValue: String?
    var isOutcomeTracked: Bool?
    var isRescue: Bool?
    var blockerReasonRawValue: String?
    var blockerNextStep: String?
    var focusSegmentsData: Data?

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        plannedMinutes: Int,
        pauseBeforeSeconds: TimeInterval?,
        intent: String? = nil,
        outcomeRawValue: String? = nil,
        isOutcomeTracked: Bool = false,
        isRescue: Bool = false,
        blockerReasonRawValue: String? = nil,
        blockerNextStep: String? = nil,
        focusSegmentsData: Data? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.pauseBeforeSeconds = pauseBeforeSeconds
        self.intent = PomodoroSession.normalizedIntent(intent)
        self.outcomeRawValue = outcomeRawValue
        self.isOutcomeTracked = isOutcomeTracked
        self.isRescue = isRescue
        self.blockerReasonRawValue = blockerReasonRawValue
        self.blockerNextStep = PomodoroSession.normalizedIntent(blockerNextStep)
        self.focusSegmentsData = focusSegmentsData
    }

    convenience init(session: PomodoroSession) {
        self.init(
            id: session.id,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            plannedMinutes: session.plannedMinutes,
            pauseBeforeSeconds: session.pauseBeforeSeconds,
            intent: session.intent,
            outcomeRawValue: session.outcome?.rawValue,
            isOutcomeTracked: session.isOutcomeTracked,
            isRescue: session.isRescue,
            blockerReasonRawValue: session.blockerReason?.rawValue,
            blockerNextStep: session.blockerNextStep,
            focusSegmentsData: Self.encodedFocusSegments(session.focusSegments)
        )
    }

    private static func encodedFocusSegments(_ focusSegments: [PomodoroFocusSegment]) -> Data? {
        try? JSONEncoder().encode(focusSegments)
    }

    fileprivate static func decodedFocusSegments(_ data: Data?) -> [PomodoroFocusSegment]? {
        guard let data else {
            return nil
        }

        return try? JSONDecoder().decode([PomodoroFocusSegment].self, from: data)
    }
}

extension PomodoroSession {
    init(record: PomodoroSessionRecord) {
        self.init(
            id: record.id,
            startedAt: record.startedAt,
            endedAt: record.endedAt,
            plannedMinutes: record.plannedMinutes,
            pauseBeforeSeconds: record.pauseBeforeSeconds,
            intent: record.intent,
            outcome: record.outcomeRawValue.flatMap(PomodoroSessionOutcome.init(rawValue:)),
            isOutcomeTracked: record.isOutcomeTracked ?? false,
            isRescue: record.isRescue ?? false,
            blockerReason: record.blockerReasonRawValue.flatMap(PomodoroBlockerReason.init(rawValue:)),
            blockerNextStep: record.blockerNextStep,
            focusSegments: PomodoroSessionRecord.decodedFocusSegments(record.focusSegmentsData)
        )
    }
}
