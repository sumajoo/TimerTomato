//
//  PomodoroSnapshot.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroSnapshot: Codable {
    var selectedMinutes: Int
    var dailyGoalSessions: Int?
    var weeklyGoalSessions: Int?
    var status: PomodoroStatus
    var activeTimerKind: PomodoroTimerKind?
    var storedDay: Date
    var sessions: [PomodoroSession]?
    var sessionHistory: [PomodoroSession]?
    var sessionHistoryMigratedToSwiftData: Bool?
    var lastCompletedAt: Date?
    var activeStartedAt: Date?
    var activeEndAt: Date?
    var activePlannedMinutes: Int?
    var activePauseBeforeSeconds: TimeInterval?
    var pausedRemainingSeconds: TimeInterval?
    var pendingFocusIntent: String? = nil
    var activeFocusIntent: String? = nil
    var pendingOutcomeSessionID: UUID? = nil
}
