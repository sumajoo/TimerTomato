//
//  PomodoroHistoryDay.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroHistoryDay: Identifiable, Equatable {
    let date: Date
    let sessions: [PomodoroSession]
    let dailyGoalSessions: Int

    var id: Date {
        date
    }

    var sessionCount: Int {
        sessions.count
    }

    var focusWinCount: Int {
        sessions.filter(\.isFocusWin).count
    }

    var completedOutcomeCount: Int {
        outcomeCount(.completed)
    }

    var progressedOutcomeCount: Int {
        outcomeCount(.progressed)
    }

    var blockedOutcomeCount: Int {
        outcomeCount(.blocked)
    }

    var rescueCount: Int {
        sessions.filter(\.isRescue).count
    }

    var hasMomentumActivity: Bool {
        sessions.contains { $0.countsAsMomentumActivity }
    }

    var primaryBlockerReason: PomodoroBlockerReason? {
        let reasonCounts = Dictionary(
            grouping: sessions.filter { $0.outcome == .blocked }.compactMap(\.blockerReason),
            by: { $0 }
        )
            .mapValues(\.count)

        return PomodoroBlockerReason.allCases
            .map { reason in (reason: reason, count: reasonCounts[reason, default: 0]) }
            .filter { $0.count > 0 }
            .sorted { first, second in
                if first.count != second.count {
                    return first.count > second.count
                }

                let firstIndex = PomodoroBlockerReason.allCases.firstIndex(of: first.reason) ?? 0
                let secondIndex = PomodoroBlockerReason.allCases.firstIndex(of: second.reason) ?? 0
                return firstIndex < secondIndex
            }
            .first?
            .reason
    }

    var latestBlockerNextStep: String? {
        sessions
            .filter { $0.outcome == .blocked }
            .sorted { $0.endedAt > $1.endedAt }
            .compactMap(\.blockerNextStep)
            .first
    }

    var focusMinutes: Int {
        sessions.reduce(0) { result, session in
            result + session.plannedMinutes
        }
    }

    var goalProgress: Double {
        guard dailyGoalSessions > 0 else {
            return 0
        }

        return min(Double(focusWinCount) / Double(dailyGoalSessions), 1)
    }

    var didReachGoal: Bool {
        focusWinCount >= dailyGoalSessions
    }

    var goalCountText: String {
        "\(min(focusWinCount, dailyGoalSessions))/\(dailyGoalSessions)"
    }

    func outcomeCount(_ outcome: PomodoroSessionOutcome) -> Int {
        sessions.filter { $0.outcome == outcome }.count
    }
}
