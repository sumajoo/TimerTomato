//
//  PomodoroTopicSummary.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import Foundation

struct PomodoroTopicSummary: Identifiable, Equatable {
    let intent: String?
    let focusSeconds: TimeInterval
    let sessionCount: Int

    var id: String {
        intent ?? "TimerTomato.Topic.None"
    }

    static func summaries(for sessions: [PomodoroSession]) -> [PomodoroTopicSummary] {
        var focusSecondsByKey: [String: TimeInterval] = [:]
        var sessionIDsByKey: [String: Set<UUID>] = [:]
        var intentByKey: [String: String?] = [:]

        for session in sessions {
            let sessionSegments = session.focusSegments.filter { $0.focusSeconds > 0 }

            for segment in sessionSegments {
                let key = key(for: segment.intent)
                focusSecondsByKey[key, default: 0] += segment.focusSeconds
                sessionIDsByKey[key, default: []].insert(session.id)
                intentByKey[key] = segment.intent
            }
        }

        return focusSecondsByKey.map { key, focusSeconds in
            PomodoroTopicSummary(
                intent: intentByKey[key] ?? nil,
                focusSeconds: focusSeconds,
                sessionCount: sessionIDsByKey[key]?.count ?? 0
            )
        }
        .sorted { first, second in
            if first.focusSeconds != second.focusSeconds {
                return first.focusSeconds > second.focusSeconds
            }

            if first.sessionCount != second.sessionCount {
                return first.sessionCount > second.sessionCount
            }

            return PomodoroFormatters.topicTitle(first.intent) < PomodoroFormatters.topicTitle(second.intent)
        }
    }

    private static func key(for intent: String?) -> String {
        PomodoroSession.normalizedIntent(intent) ?? "TimerTomato.Topic.None"
    }
}
