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
    var cloudSyncVersion = 0

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
        focusSegmentsData: Data? = nil,
        cloudSyncVersion: Int = 1
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
        self.cloudSyncVersion = cloudSyncVersion
    }

    convenience init(session: PomodoroSession, cloudSyncVersion: Int = 1) {
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
            focusSegmentsData: Self.encodedFocusSegments(session.focusSegments),
            cloudSyncVersion: cloudSyncVersion
        )
    }

    func updateIntent(_ intent: String?) {
        let normalizedIntent = PomodoroSession.normalizedIntent(intent)
        self.intent = normalizedIntent

        let existingSegments = Self.decodedFocusSegments(focusSegmentsData)
        let segments = existingSegments?.isEmpty == false ? existingSegments! : [
            PomodoroFocusSegment(
                intent: normalizedIntent,
                startedFocusSeconds: 0,
                focusSeconds: TimeInterval(max(plannedMinutes, 0) * 60)
            )
        ]

        focusSegmentsData = Self.encodedFocusSegments(
            segments.map { segment in
                PomodoroFocusSegment(
                    id: segment.id,
                    intent: normalizedIntent,
                    startedFocusSeconds: segment.startedFocusSeconds,
                    focusSeconds: segment.focusSeconds
                )
            }
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
