//
//  PomodoroStore.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class PomodoroStore {
    static let defaultMinutes = 25
    static let minimumMinutes = 5
    static let maximumMinutes = 90
    static let minuteStep = 5

    var selectedMinutes = PomodoroStore.defaultMinutes {
        didSet {
            let clampedMinutes = Self.clampedMinutes(selectedMinutes)

            if selectedMinutes != clampedMinutes {
                selectedMinutes = clampedMinutes
                return
            }

            guard !isRestoringSnapshot else {
                return
            }

            persistSnapshot()
        }
    }

    private(set) var status = PomodoroStatus.idle
    private(set) var sessions: [PomodoroSession] = []
    private(set) var currentDate: Date
    private(set) var activeStartedAt: Date?
    private(set) var activeEndAt: Date?
    private(set) var activePlannedMinutes: Int?
    private(set) var activePauseBeforeSeconds: TimeInterval?
    private(set) var pausedRemainingSeconds: TimeInterval?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let persistenceKey: String
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let nowProvider: () -> Date
    @ObservationIgnored private let notifier: any PomodoroNotifying
    @ObservationIgnored private let shouldScheduleTimer: Bool
    @ObservationIgnored private var storedDay: Date
    @ObservationIgnored private var lastCompletedAt: Date?
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var isRestoringSnapshot = false

    var menuBarTitle: String {
        remainingClockText
    }

    var menuBarAccessibilityLabel: String {
        "TimerTomato, verbleibende Zeit \(remainingClockText)"
    }

    var menuBarSystemImage: String {
        switch status {
        case .idle:
            "timer"
        case .running:
            "timer.circle.fill"
        case .paused:
            "pause.circle.fill"
        }
    }

    var remainingSeconds: Int {
        switch status {
        case .idle:
            selectedMinutes * 60
        case .paused:
            Int(ceil(max(0, pausedRemainingSeconds ?? 0)))
        case .running:
            Int(ceil(max(0, activeEndAt?.timeIntervalSince(currentDate) ?? 0)))
        }
    }

    var remainingClockText: String {
        PomodoroFormatters.clockText(seconds: remainingSeconds)
    }

    var progress: Double {
        guard status != .idle else {
            return 0
        }

        let totalSeconds = Double((activePlannedMinutes ?? selectedMinutes) * 60)
        guard totalSeconds > 0 else {
            return 0
        }

        return min(max(1 - (Double(remainingSeconds) / totalSeconds), 0), 1)
    }

    var sessionsCompletedToday: Int {
        sessions.count
    }

    var focusMinutesToday: Int {
        sessions.reduce(0) { result, session in
            result + session.plannedMinutes
        }
    }

    init(
        defaults: UserDefaults = .standard,
        persistenceKey: String = "TimerTomato.PomodoroStore",
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init,
        notifier: any PomodoroNotifying = UserNotificationScheduler(),
        shouldScheduleTimer: Bool = true
    ) {
        let initialDate = now()

        self.defaults = defaults
        self.persistenceKey = persistenceKey
        self.calendar = calendar
        self.nowProvider = now
        self.notifier = notifier
        self.shouldScheduleTimer = shouldScheduleTimer
        self.currentDate = initialDate
        self.storedDay = calendar.startOfDay(for: initialDate)

        restoreSnapshot()
        refreshForToday(at: initialDate)

        if status == .running {
            if remainingSeconds <= 0 {
                completeCurrentSession(at: activeEndAt ?? initialDate)
            } else {
                scheduleTimer()
            }
        }
    }

    func start() {
        let startDate = nowProvider()
        refreshForToday(at: startDate)

        guard status == .idle else {
            return
        }

        let durationSeconds = TimeInterval(selectedMinutes * 60)

        activeStartedAt = startDate
        activeEndAt = startDate.addingTimeInterval(durationSeconds)
        activePlannedMinutes = selectedMinutes
        activePauseBeforeSeconds = lastCompletedAt.map { max(0, startDate.timeIntervalSince($0)) }
        pausedRemainingSeconds = nil
        status = .running
        currentDate = startDate

        persistSnapshot()
        scheduleTimer()

        Task {
            await notifier.requestAuthorizationIfNeeded()
        }
    }

    func pause() {
        updateCurrentDate()

        guard status == .running else {
            return
        }

        pausedRemainingSeconds = TimeInterval(remainingSeconds)
        status = .paused

        timer?.invalidate()
        timer = nil
        persistSnapshot()
    }

    func resume() {
        let resumeDate = nowProvider()

        guard status == .paused else {
            return
        }

        currentDate = resumeDate
        activeEndAt = resumeDate.addingTimeInterval(pausedRemainingSeconds ?? 0)
        pausedRemainingSeconds = nil
        status = .running

        persistSnapshot()
        scheduleTimer()
    }

    func reset() {
        timer?.invalidate()
        timer = nil

        status = .idle
        activeStartedAt = nil
        activeEndAt = nil
        activePlannedMinutes = nil
        activePauseBeforeSeconds = nil
        pausedRemainingSeconds = nil
        currentDate = nowProvider()

        persistSnapshot()
    }

    func decreaseSelectedMinutes() {
        selectedMinutes -= Self.minuteStep
    }

    func increaseSelectedMinutes() {
        selectedMinutes += Self.minuteStep
    }

    func refreshForToday() {
        refreshForToday(at: nowProvider())
    }

    func tick() {
        updateCurrentDate()

        guard status == .running, remainingSeconds <= 0 else {
            return
        }

        completeCurrentSession(at: activeEndAt ?? currentDate)
    }

    static func clampedMinutes(_ minutes: Int) -> Int {
        min(max(minutes, minimumMinutes), maximumMinutes)
    }

    private func refreshForToday(at date: Date) {
        currentDate = date

        guard !calendar.isDate(storedDay, inSameDayAs: date) else {
            return
        }

        sessions = []
        lastCompletedAt = nil
        storedDay = calendar.startOfDay(for: date)
        persistSnapshot()
    }

    private func updateCurrentDate() {
        currentDate = nowProvider()
    }

    private func completeCurrentSession(at completionDate: Date) {
        guard let startedAt = activeStartedAt else {
            reset()
            return
        }

        let plannedMinutes = activePlannedMinutes ?? selectedMinutes
        let endedAt = max(completionDate, startedAt)
        let session = PomodoroSession(
            startedAt: startedAt,
            endedAt: endedAt,
            plannedMinutes: plannedMinutes,
            pauseBeforeSeconds: activePauseBeforeSeconds
        )

        sessions.append(session)
        lastCompletedAt = endedAt
        status = .idle
        activeStartedAt = nil
        activeEndAt = nil
        activePlannedMinutes = nil
        activePauseBeforeSeconds = nil
        pausedRemainingSeconds = nil
        currentDate = endedAt

        timer?.invalidate()
        timer = nil

        persistSnapshot()

        Task {
            await notifier.notifySessionCompleted(plannedMinutes: plannedMinutes)
        }
    }

    private func scheduleTimer() {
        guard shouldScheduleTimer else {
            return
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func restoreSnapshot() {
        guard
            let data = defaults.data(forKey: persistenceKey),
            let snapshot = try? JSONDecoder().decode(PomodoroSnapshot.self, from: data)
        else {
            return
        }

        isRestoringSnapshot = true
        selectedMinutes = Self.clampedMinutes(snapshot.selectedMinutes)
        status = snapshot.status
        storedDay = snapshot.storedDay
        sessions = snapshot.sessions
        lastCompletedAt = snapshot.lastCompletedAt
        activeStartedAt = snapshot.activeStartedAt
        activeEndAt = snapshot.activeEndAt
        activePlannedMinutes = snapshot.activePlannedMinutes
        activePauseBeforeSeconds = snapshot.activePauseBeforeSeconds
        pausedRemainingSeconds = snapshot.pausedRemainingSeconds
        isRestoringSnapshot = false
    }

    private func persistSnapshot() {
        let snapshot = PomodoroSnapshot(
            selectedMinutes: selectedMinutes,
            status: status,
            storedDay: storedDay,
            sessions: sessions,
            lastCompletedAt: lastCompletedAt,
            activeStartedAt: activeStartedAt,
            activeEndAt: activeEndAt,
            activePlannedMinutes: activePlannedMinutes,
            activePauseBeforeSeconds: activePauseBeforeSeconds,
            pausedRemainingSeconds: pausedRemainingSeconds
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: persistenceKey)
    }
}
