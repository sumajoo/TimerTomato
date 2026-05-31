//
//  PomodoroSession.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

enum PomodoroSessionOutcome: String, Codable, CaseIterable, Equatable {
    case completed
    case progressed
    case blocked

    var title: String {
        switch self {
        case .completed:
            "Erledigt"
        case .progressed:
            "Fortschritt"
        case .blocked:
            "Blockiert"
        }
    }

    var shortTitle: String {
        switch self {
        case .completed:
            "Erledigt"
        case .progressed:
            "Fortschritt"
        case .blocked:
            "Blockiert"
        }
    }

    var systemImage: String {
        switch self {
        case .completed:
            "checkmark.circle.fill"
        case .progressed:
            "arrow.up.right.circle.fill"
        case .blocked:
            "exclamationmark.circle.fill"
        }
    }

    var countsAsFocusWin: Bool {
        switch self {
        case .completed, .progressed:
            true
        case .blocked:
            false
        }
    }
}

struct PomodoroSession: Identifiable, Codable, Equatable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let plannedMinutes: Int
    let pauseBeforeSeconds: TimeInterval?
    let intent: String?
    let outcome: PomodoroSessionOutcome?
    let isOutcomeTracked: Bool
    let isRescue: Bool
    let blockerReason: PomodoroBlockerReason?
    let blockerNextStep: String?

    var focusSeconds: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }

    var intentTitle: String? {
        Self.normalizedIntent(intent)
    }

    var displayTitle: String {
        intentTitle ?? "\(plannedMinutes) Minuten Fokus"
    }

    var isPendingOutcome: Bool {
        isOutcomeTracked && outcome == nil
    }

    var isFocusWin: Bool {
        !isRescue && (!isOutcomeTracked || outcome?.countsAsFocusWin == true)
    }

    var countsAsMomentumActivity: Bool {
        if isPendingOutcome {
            return false
        }

        return !isOutcomeTracked || outcome != nil
    }

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        plannedMinutes: Int,
        pauseBeforeSeconds: TimeInterval?,
        intent: String? = nil,
        outcome: PomodoroSessionOutcome? = nil,
        isOutcomeTracked: Bool = false,
        isRescue: Bool = false,
        blockerReason: PomodoroBlockerReason? = nil,
        blockerNextStep: String? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.pauseBeforeSeconds = pauseBeforeSeconds
        self.intent = Self.normalizedIntent(intent)
        self.outcome = outcome
        self.isOutcomeTracked = isOutcomeTracked
        self.isRescue = isRescue
        self.blockerReason = blockerReason
        self.blockerNextStep = Self.normalizedIntent(blockerNextStep)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        endedAt = try container.decode(Date.self, forKey: .endedAt)
        plannedMinutes = try container.decode(Int.self, forKey: .plannedMinutes)
        pauseBeforeSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .pauseBeforeSeconds)
        intent = Self.normalizedIntent(try container.decodeIfPresent(String.self, forKey: .intent))
        outcome = try container.decodeIfPresent(PomodoroSessionOutcome.self, forKey: .outcome)
        isOutcomeTracked = try container.decodeIfPresent(Bool.self, forKey: .isOutcomeTracked) ?? false
        isRescue = try container.decodeIfPresent(Bool.self, forKey: .isRescue) ?? false
        blockerReason = try container.decodeIfPresent(PomodoroBlockerReason.self, forKey: .blockerReason)
        blockerNextStep = Self.normalizedIntent(try container.decodeIfPresent(String.self, forKey: .blockerNextStep))
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encode(endedAt, forKey: .endedAt)
        try container.encode(plannedMinutes, forKey: .plannedMinutes)
        try container.encodeIfPresent(pauseBeforeSeconds, forKey: .pauseBeforeSeconds)
        try container.encodeIfPresent(intent, forKey: .intent)
        try container.encodeIfPresent(outcome, forKey: .outcome)
        try container.encode(isOutcomeTracked, forKey: .isOutcomeTracked)
        try container.encode(isRescue, forKey: .isRescue)
        try container.encodeIfPresent(blockerReason, forKey: .blockerReason)
        try container.encodeIfPresent(blockerNextStep, forKey: .blockerNextStep)
    }

    nonisolated static func normalizedIntent(_ intent: String?) -> String? {
        guard let intent else {
            return nil
        }

        let trimmedIntent = intent.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedIntent.isEmpty ? nil : trimmedIntent
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case startedAt
        case endedAt
        case plannedMinutes
        case pauseBeforeSeconds
        case intent
        case outcome
        case isOutcomeTracked
        case isRescue
        case blockerReason
        case blockerNextStep
    }
}
