//
//  TimerTomatoTests.swift
//  TimerTomatoTests
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
import SwiftData
import Testing
@testable import TimerTomato

@MainActor
struct TimerTomatoTests {
    @Test func defaultDurationAndClampingPersist() async {
        let defaults = makeDefaults()

        let store = makeStore(defaults: defaults)
        #expect(store.selectedMinutes == 25)
        #expect(store.menuBarTitle == "25:00")

        store.selectedMinutes = 120
        #expect(store.selectedMinutes == 90)
        #expect(store.menuBarTitle == "1:30:00")

        var restored = makeStore(defaults: defaults)
        #expect(restored.selectedMinutes == 90)

        restored.selectedMinutes = 1
        #expect(restored.selectedMinutes == 5)

        restored = makeStore(defaults: defaults)
        #expect(restored.selectedMinutes == 5)
    }

    @Test func durationPresetSelectionPersists() async {
        let defaults = makeDefaults()
        let store = makeStore(defaults: defaults)

        store.selectPreset(minutes: 10)

        #expect(store.selectedMinutes == 10)

        let restored = makeStore(defaults: defaults)
        #expect(restored.selectedMinutes == 10)
    }

    @Test func dailyGoalPersistsAndClamps() async {
        let defaults = makeDefaults()
        let store = makeStore(defaults: defaults)

        #expect(store.dailyGoalSessions == 4)
        #expect(store.dailyGoalProgress == 0)

        store.dailyGoalSessions = 20
        #expect(store.dailyGoalSessions == 12)

        var restored = makeStore(defaults: defaults)
        #expect(restored.dailyGoalSessions == 12)

        restored.dailyGoalSessions = 0
        #expect(restored.dailyGoalSessions == 1)

        restored = makeStore(defaults: defaults)
        #expect(restored.dailyGoalSessions == 1)
    }

    @Test func weeklyGoalInitializesPersistsAndClamps() async {
        let defaults = makeDefaults()
        let store = makeStore(defaults: defaults)

        #expect(store.weeklyGoalSessions == 20)

        store.weeklyGoalSessions = 200
        #expect(store.weeklyGoalSessions == 84)

        var restored = makeStore(defaults: defaults)
        #expect(restored.weeklyGoalSessions == 84)

        restored.weeklyGoalSessions = 0
        #expect(restored.weeklyGoalSessions == 1)

        restored = makeStore(defaults: defaults)
        #expect(restored.weeklyGoalSessions == 1)
    }

    @Test func completedSessionIsRecorded() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()
        await Task.yield()

        #expect(store.status == .idle)
        #expect(store.sessions.count == 1)
        #expect(store.sessionHistory.count == 1)
        #expect(store.sessions[0].plannedMinutes == 25)
        #expect(store.sessions[0].pauseBeforeSeconds == nil)
        #expect(notifier.completedSessionMinutes == [25])
    }

    @Test func pauseBetweenSessionsIsMeasuredFromPreviousCompletion() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()

        now = date(hour: 9, minute: 35)
        store.start()
        now = date(hour: 10, minute: 0)
        store.tick()

        #expect(store.sessions.count == 2)
        #expect(store.sessions[1].pauseBeforeSeconds == 600)
    }

    @Test func todaySummaryIncludesSessionsMinutesAndAveragePause() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()

        now = date(hour: 9, minute: 34)
        store.start()
        now = date(hour: 9, minute: 59)
        store.tick()

        #expect(store.sessionsCompletedToday == 2)
        #expect(store.focusMinutesToday == 50)
        #expect(store.averagePauseSecondsToday == 540)
        #expect(store.dailyGoalProgress == 0.5)
        #expect(store.dailyGoalCountText == "2/4")
        #expect(store.dailyGoalStatusText == "Noch 2 Sitzungen")
        #expect(store.compactTodaySummaryText == "2 · 50 min")
        #expect(store.todaySummaryText == "2 Sitzungen · 50 min · Ø Pause 9 min")
    }

    @Test func breakTimerCompletesWithoutRecordingSession() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()

        store.startBreak()
        #expect(store.status == .running)
        #expect(store.activeTimerKind == .breakTime)
        #expect(store.remainingSeconds == 300)

        now = date(hour: 9, minute: 30)
        store.tick()
        await Task.yield()

        #expect(store.status == .idle)
        #expect(store.activeTimerKind == .focus)
        #expect(store.sessions.count == 1)
        #expect(notifier.completedBreakMinutes == [5])
    }

    @Test func resetDoesNotRecordSession() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 10)
        store.reset()

        #expect(store.status == .idle)
        #expect(store.sessions.isEmpty)
    }

    @Test func dayRolloverClearsVisibleTodayLogAndKeepsHistory() async {
        let defaults = makeDefaults()
        var now = date(day: 1, hour: 23, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(day: 1, hour: 23, minute: 25)
        store.tick()

        #expect(store.sessions.count == 1)

        now = date(day: 2, hour: 0, minute: 1)
        store.refreshForToday()

        #expect(store.sessions.isEmpty)
        #expect(store.sessionsCompletedToday == 0)
        #expect(store.sessionHistory.count == 1)
        #expect(store.sessions(on: date(day: 1, hour: 12, minute: 0)).count == 1)
    }

    @Test func historyWeekAggregatesSessionsByDay() async {
        let defaults = makeDefaults()
        var now = date(day: 18, hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(day: 18, hour: 9, minute: 25)
        store.tick()

        now = date(day: 19, hour: 10, minute: 0)
        store.refreshForToday()
        store.start()
        now = date(day: 19, hour: 10, minute: 25)
        store.tick()

        now = date(day: 19, hour: 11, minute: 0)
        store.start()
        now = date(day: 19, hour: 11, minute: 25)
        store.tick()

        let days = store.historyDays(containing: date(day: 19, hour: 12, minute: 0))
        let firstDay = days.first { store.isSameDay($0.date, date(day: 18, hour: 12, minute: 0)) }
        let secondDay = days.first { store.isSameDay($0.date, date(day: 19, hour: 12, minute: 0)) }

        #expect(days.count == 7)
        #expect(firstDay?.sessionCount == 1)
        #expect(firstDay?.focusMinutes == 25)
        #expect(secondDay?.sessionCount == 2)
        #expect(secondDay?.focusMinutes == 50)
    }

    @Test func weeklyGoalSuggestionUsesCompletedWeeksOnly() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            makeSessions(day: 1, count: 6)
                + makeSessions(day: 4, count: 8)
                + makeSessions(day: 11, count: 10)
                + makeSessions(day: 18, count: 20),
            in: modelContainer
        )

        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 24, hour: 12, minute: 0) }
        )

        #expect(store.weeklyGoalSuggestionSessions == 9)
        #expect(store.weeklyGoalSessions == 9)
    }

    @Test func weekSummaryCalculatesProgressAndFocusMinutes() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            [
                session(day: 18, startHour: 9, startMinute: 0, durationMinutes: 45),
                session(day: 18, startHour: 10, startMinute: 0, durationMinutes: 30),
                session(day: 19, startHour: 11, startMinute: 0, durationMinutes: 25)
            ],
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 24, hour: 12, minute: 0) }
        )

        store.weeklyGoalSessions = 6
        let summary = store.weekSummary(containing: date(day: 24, hour: 12, minute: 0))

        #expect(summary.sessionCount == 3)
        #expect(summary.focusMinutes == 100)
        #expect(summary.goalProgress == 0.5)
        #expect(summary.goalCountText == "3/6")
        #expect(summary.didReachGoal == false)
    }

    @Test func streakCountsReachedDailyGoalsWithoutBreakingOnIncompleteToday() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            makeSessions(day: 20, count: 2)
                + makeSessions(day: 21, count: 2)
                + makeSessions(day: 22, count: 1)
                + makeSessions(day: 23, count: 2)
                + makeSessions(day: 24, count: 1),
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 24, hour: 12, minute: 0) }
        )

        store.dailyGoalSessions = 2

        #expect(store.streakSummary.currentDays == 1)
        #expect(store.streakSummary.bestDays == 2)
        #expect(store.streakSummary.latestGoalDate == date(day: 23, hour: 0, minute: 0))
    }

    @Test func bestFocusDaysSortByMinutesSessionsThenNewestDate() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            [
                session(day: 10, startHour: 9, startMinute: 0, durationMinutes: 30),
                session(day: 10, startHour: 10, startMinute: 0, durationMinutes: 30),
                session(day: 10, startHour: 11, startMinute: 0, durationMinutes: 30),
                session(day: 11, startHour: 9, startMinute: 0, durationMinutes: 50),
                session(day: 11, startHour: 10, startMinute: 0, durationMinutes: 50),
                session(day: 12, startHour: 9, startMinute: 0, durationMinutes: 25),
                session(day: 12, startHour: 10, startMinute: 0, durationMinutes: 25),
                session(day: 12, startHour: 11, startMinute: 0, durationMinutes: 25),
                session(day: 12, startHour: 12, startMinute: 0, durationMinutes: 25)
            ],
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 24, hour: 12, minute: 0) }
        )
        let bestDays = store.bestFocusDays(limit: 3)

        #expect(bestDays.map(\.date) == [
            date(day: 12, hour: 0, minute: 0),
            date(day: 11, hour: 0, minute: 0),
            date(day: 10, hour: 0, minute: 0)
        ])
        #expect(bestDays.map(\.focusMinutes) == [100, 100, 90])
        #expect(bestDays.map(\.sessionCount) == [4, 2, 3])
    }

    @Test func historyLookupRestoresAcrossStoreInstances() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(day: 18, hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.start()
        now = date(day: 18, hour: 9, minute: 25)
        store.tick()

        now = date(day: 20, hour: 10, minute: 0)
        store.refreshForToday()
        store.start()
        now = date(day: 20, hour: 10, minute: 25)
        store.tick()

        let restored = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 20, hour: 12, minute: 0) }
        )
        let firstDaySessions = restored.sessions(on: date(day: 18, hour: 12, minute: 0))
        let thirdDaySessions = restored.sessions(on: date(day: 20, hour: 12, minute: 0))
        let days = restored.historyDays(containing: date(day: 20, hour: 12, minute: 0))
        let firstDay = days.first { restored.isSameDay($0.date, date(day: 18, hour: 12, minute: 0)) }
        let thirdDay = days.first { restored.isSameDay($0.date, date(day: 20, hour: 12, minute: 0)) }

        #expect(firstDaySessions.count == 1)
        #expect(thirdDaySessions.count == 1)
        #expect(firstDay?.sessionCount == 1)
        #expect(thirdDay?.sessionCount == 1)
    }

    @Test func legacySessionHistoryMigratesToSwiftDataOnce() async throws {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        let legacySession = PomodoroSession(
            startedAt: date(day: 18, hour: 9, minute: 0),
            endedAt: date(day: 18, hour: 9, minute: 25),
            plannedMinutes: 25,
            pauseBeforeSeconds: nil
        )
        let snapshot = PomodoroSnapshot(
            selectedMinutes: 25,
            dailyGoalSessions: 4,
            weeklyGoalSessions: nil,
            status: .idle,
            activeTimerKind: .focus,
            storedDay: date(day: 18, hour: 0, minute: 0),
            sessions: [legacySession],
            sessionHistory: [legacySession],
            sessionHistoryMigratedToSwiftData: false,
            lastCompletedAt: legacySession.endedAt,
            activeStartedAt: nil,
            activeEndAt: nil,
            activePlannedMinutes: nil,
            activePauseBeforeSeconds: nil,
            pausedRemainingSeconds: nil
        )
        let data = try JSONEncoder().encode(snapshot)

        defaults.set(data, forKey: "PomodoroStore")

        let migrated = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 18, hour: 12, minute: 0) }
        )
        let restored = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 18, hour: 12, minute: 0) }
        )

        #expect(migrated.sessionHistory.count == 1)
        #expect(restored.sessionHistory.count == 1)
        #expect(restored.sessions(on: date(day: 18, hour: 12, minute: 0)).count == 1)
    }

    @Test func activeTimerRestoresFromAbsoluteDates() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 5)

        let restored = makeStore(defaults: defaults, now: { now })

        #expect(restored.status == .running)
        #expect(restored.remainingSeconds == 1_200)
        #expect(restored.activeStartedAt == date(hour: 9, minute: 0))
    }

    @Test func expiredTimerCompletesDuringRestore() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.start()
        now = date(hour: 9, minute: 30)

        let restoredNotifier = TestPomodoroNotifier()
        let restored = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { now },
            notifier: restoredNotifier
        )
        await Task.yield()

        #expect(restored.status == .idle)
        #expect(restored.sessions.count == 1)
        #expect(restored.sessionHistory.count == 1)
        #expect(restored.sessions[0].endedAt == date(hour: 9, minute: 25))
        #expect(restoredNotifier.completedSessionMinutes == [25])
    }

    @Test func lifecycleRefreshCompletesExpiredRunningTimer() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.start()
        now = date(hour: 9, minute: 30)
        store.refreshLifecycleState()
        await Task.yield()

        #expect(store.status == .idle)
        #expect(store.sessions.count == 1)
        #expect(store.sessions[0].endedAt == date(hour: 9, minute: 25))
        #expect(notifier.completedSessionMinutes == [25])
    }

    @Test func activeBreakTimerRestoresFromAbsoluteDates() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()
        store.startBreak()

        now = date(hour: 9, minute: 27)
        let restored = makeStore(defaults: defaults, now: { now })

        #expect(restored.status == .running)
        #expect(restored.activeTimerKind == .breakTime)
        #expect(restored.remainingSeconds == 180)
    }

    @Test func deniedNotificationPermissionIsVisibleAndTimerStillStarts() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        notifier.permission = .denied
        let store = makeStore(defaults: defaults, notifier: notifier)

        store.start()
        await Task.yield()

        #expect(store.status == .running)
        #expect(store.notificationPermission == .denied)
        #expect(store.notificationWarningText == "Mitteilungen deaktiviert")
        #expect(notifier.authorizationRequestCount == 1)
    }

    @Test func notificationActionStartsNextFocusSession() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()

        now = date(hour: 9, minute: 35)
        notifier.perform(action: .startNextFocus)

        #expect(store.status == .running)
        #expect(store.sessions.count == 1)
        #expect(store.activeStartedAt == date(hour: 9, minute: 35))
        #expect(store.activePauseBeforeSeconds == 600)
    }

    @Test func notificationActionStartsBreakTimer() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()

        now = date(hour: 9, minute: 26)
        notifier.perform(action: .startBreak)

        #expect(store.status == .running)
        #expect(store.activeTimerKind == .breakTime)
        #expect(store.activeStartedAt == date(hour: 9, minute: 26))
    }

    private func makeStore(
        defaults: UserDefaults,
        modelContainer: ModelContainer? = nil,
        now: @escaping () -> Date = { Date(timeIntervalSince1970: 0) },
        notifier: TestPomodoroNotifier = TestPomodoroNotifier()
    ) -> PomodoroStore {
        PomodoroStore(
            defaults: defaults,
            persistenceKey: "PomodoroStore",
            modelContainer: modelContainer ?? makeModelContainer(),
            calendar: testCalendar,
            now: now,
            notifier: notifier,
            shouldScheduleTimer: false
        )
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "TimerTomatoTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private func makeModelContainer() -> ModelContainer {
        do {
            return try TimerTomatoModelContainer.make(isStoredInMemoryOnly: true)
        } catch {
            fatalError("Could not create test model container: \(error)")
        }
    }

    private func seedSessions(_ sessions: [PomodoroSession], in modelContainer: ModelContainer) {
        let context = modelContainer.mainContext

        sessions.forEach { session in
            context.insert(PomodoroSessionRecord(session: session))
        }

        do {
            try context.save()
        } catch {
            fatalError("Could not seed test sessions: \(error)")
        }
    }

    private func makeSessions(day: Int, count: Int) -> [PomodoroSession] {
        (0..<count).map { index in
            session(
                day: day,
                startHour: 8 + (index / 2),
                startMinute: (index % 2) * 30
            )
        }
    }

    private func session(
        day: Int,
        startHour: Int,
        startMinute: Int,
        durationMinutes: Int = PomodoroStore.defaultMinutes
    ) -> PomodoroSession {
        let startedAt = date(day: day, hour: startHour, minute: startMinute)
        let endedAt = testCalendar.date(byAdding: .minute, value: durationMinutes, to: startedAt) ?? startedAt

        return PomodoroSession(
            startedAt: startedAt,
            endedAt: endedAt,
            plannedMinutes: durationMinutes,
            pauseBeforeSeconds: nil
        )
    }

    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(day: Int = 1, hour: Int, minute: Int) -> Date {
        DateComponents(
            calendar: testCalendar,
            timeZone: testCalendar.timeZone,
            year: 2026,
            month: 5,
            day: day,
            hour: hour,
            minute: minute
        ).date!
    }
}
