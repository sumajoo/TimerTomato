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
            "Weitergekommen"
        case .blocked:
            "Blockiert"
        }
    }

    var shortTitle: String {
        switch self {
        case .completed:
            "Erledigt"
        case .progressed:
            "Weiter"
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
        !isOutcomeTracked || outcome?.countsAsFocusWin == true
    }

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        plannedMinutes: Int,
        pauseBeforeSeconds: TimeInterval?,
        intent: String? = nil,
        outcome: PomodoroSessionOutcome? = nil,
        isOutcomeTracked: Bool = false
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.pauseBeforeSeconds = pauseBeforeSeconds
        self.intent = Self.normalizedIntent(intent)
        self.outcome = outcome
        self.isOutcomeTracked = isOutcomeTracked
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
    }
}
