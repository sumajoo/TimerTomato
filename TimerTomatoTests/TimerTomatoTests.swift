//
//  TimerTomatoTests.swift
//  TimerTomatoTests
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
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

    @Test func dayRolloverClearsVisibleTodayLog() async {
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

    private func makeStore(
        defaults: UserDefaults,
        now: @escaping () -> Date = { Date(timeIntervalSince1970: 0) },
        notifier: TestPomodoroNotifier = TestPomodoroNotifier()
    ) -> PomodoroStore {
        PomodoroStore(
            defaults: defaults,
            persistenceKey: "PomodoroStore",
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

    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
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
