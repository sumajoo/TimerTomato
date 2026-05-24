//
//  TimerTomatoPreviewData.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

#if DEBUG
import Foundation
import SwiftData

@MainActor
enum TimerTomatoPreviewData {
    enum TimerState {
        case idle
        case focusRunning
        case focusPaused
        case breakRunning
    }

    static let referenceDate = date(day: 24, hour: 15, minute: 30)

    static var sampleSession: PomodoroSession {
        todaySessions[0]
    }

    static var sampleHistoryDay: PomodoroHistoryDay {
        PomodoroHistoryDay(
            date: referenceDate,
            sessions: todaySessions,
            dailyGoalSessions: PomodoroStore.defaultDailyGoalSessions
        )
    }

    static var emptyHistoryDay: PomodoroHistoryDay {
        PomodoroHistoryDay(
            date: date(day: 20, hour: 12, minute: 0),
            sessions: [],
            dailyGoalSessions: PomodoroStore.defaultDailyGoalSessions
        )
    }

    static var todaySessions: [PomodoroSession] {
        [
            session(day: 24, startHour: 12, startMinute: 59, pauseBeforeSeconds: nil),
            session(day: 24, startHour: 13, startMinute: 34, pauseBeforeSeconds: 9 * 60),
            session(day: 24, startHour: 14, startMinute: 29, pauseBeforeSeconds: 29 * 60),
            session(day: 24, startHour: 15, startMinute: 0, pauseBeforeSeconds: 6 * 60)
        ]
    }

    static var historySessions: [PomodoroSession] {
        [
            session(day: 4, startHour: 9, startMinute: 0, pauseBeforeSeconds: nil),
            session(day: 4, startHour: 9, startMinute: 35, pauseBeforeSeconds: 10 * 60),
            session(day: 5, startHour: 11, startMinute: 0, pauseBeforeSeconds: nil),
            session(day: 11, startHour: 8, startMinute: 45, pauseBeforeSeconds: nil),
            session(day: 11, startHour: 9, startMinute: 20, pauseBeforeSeconds: 10 * 60),
            session(day: 12, startHour: 14, startMinute: 0, pauseBeforeSeconds: nil),
            session(day: 12, startHour: 14, startMinute: 35, pauseBeforeSeconds: 10 * 60),
            session(day: 18, startHour: 9, startMinute: 0, pauseBeforeSeconds: nil),
            session(day: 19, startHour: 10, startMinute: 0, pauseBeforeSeconds: nil),
            session(day: 19, startHour: 10, startMinute: 35, pauseBeforeSeconds: 10 * 60),
            session(day: 21, startHour: 14, startMinute: 0, pauseBeforeSeconds: nil),
            session(day: 22, startHour: 8, startMinute: 45, pauseBeforeSeconds: nil),
            session(day: 22, startHour: 9, startMinute: 20, pauseBeforeSeconds: 10 * 60)
        ] + todaySessions
    }

    static func store(
        selectedMinutes: Int = PomodoroStore.defaultMinutes,
        dailyGoalSessions: Int = PomodoroStore.defaultDailyGoalSessions,
        sessions: [PomodoroSession] = todaySessions,
        timerState: TimerState = .idle
    ) -> PomodoroStore {
        var now = referenceDate
        let container = makeModelContainer()
        let context = container.mainContext

        sessions.forEach { session in
            context.insert(PomodoroSessionRecord(session: session))
        }

        do {
            try context.save()
        } catch {
            fatalError("Could not seed TimerTomato previews: \(error)")
        }

        let store = PomodoroStore(
            defaults: makeDefaults(),
            persistenceKey: "TimerTomatoPreview",
            modelContainer: container,
            calendar: previewCalendar,
            now: { now },
            notifier: PreviewPomodoroNotifier(),
            shouldScheduleTimer: false
        )
        store.selectedMinutes = selectedMinutes
        store.dailyGoalSessions = dailyGoalSessions

        switch timerState {
        case .idle:
            break
        case .focusRunning:
            store.start()
            now = referenceDate.addingTimeInterval(54)
            store.tick()
        case .focusPaused:
            store.start()
            now = referenceDate.addingTimeInterval(9 * 60)
            store.pause()
        case .breakRunning:
            store.startBreak()
            now = referenceDate.addingTimeInterval(2 * 60)
            store.tick()
        }

        return store
    }

    static func session(
        day: Int = 24,
        startHour: Int,
        startMinute: Int,
        durationMinutes: Int = PomodoroStore.defaultMinutes,
        pauseBeforeSeconds: TimeInterval?
    ) -> PomodoroSession {
        let startedAt = date(day: day, hour: startHour, minute: startMinute)
        let endedAt = previewCalendar.date(
            byAdding: .minute,
            value: durationMinutes,
            to: startedAt
        ) ?? startedAt

        return PomodoroSession(
            startedAt: startedAt,
            endedAt: endedAt,
            plannedMinutes: durationMinutes,
            pauseBeforeSeconds: pauseBeforeSeconds
        )
    }

    static func date(day: Int, hour: Int, minute: Int) -> Date {
        DateComponents(
            calendar: previewCalendar,
            timeZone: previewCalendar.timeZone,
            year: 2026,
            month: 5,
            day: day,
            hour: hour,
            minute: minute
        ).date ?? Date(timeIntervalSince1970: 0)
    }

    private static var previewCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "de_DE")
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .current
        calendar.firstWeekday = 2
        return calendar
    }

    private static func makeDefaults() -> UserDefaults {
        let suiteName = "TimerTomatoPreview.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private static func makeModelContainer() -> ModelContainer {
        do {
            return try TimerTomatoModelContainer.make(isStoredInMemoryOnly: true)
        } catch {
            fatalError("Could not create TimerTomato preview model container: \(error)")
        }
    }
}
#endif
