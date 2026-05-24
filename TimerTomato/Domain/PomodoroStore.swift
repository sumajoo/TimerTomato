//
//  PomodoroStore.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

@preconcurrency import AppKit
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class PomodoroStore {
    static let defaultMinutes = 25
    static let minimumMinutes = 5
    static let maximumMinutes = 90
    static let minuteStep = 5
    static let breakMinutes = 5
    static let defaultDailyGoalSessions = 4
    static let minimumDailyGoalSessions = 1
    static let maximumDailyGoalSessions = 12
    static let defaultWeeklyGoalSessions = defaultDailyGoalSessions * 5
    static let minimumWeeklyGoalSessions = 1
    static let maximumWeeklyGoalSessions = maximumDailyGoalSessions * 7
    static let durationPresets = [10, 15, 25, 45, 60]

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

    var dailyGoalSessions = PomodoroStore.defaultDailyGoalSessions {
        didSet {
            let clampedSessions = Self.clampedDailyGoalSessions(dailyGoalSessions)

            if dailyGoalSessions != clampedSessions {
                dailyGoalSessions = clampedSessions
                return
            }

            guard !isRestoringSnapshot else {
                return
            }

            persistSnapshot()
        }
    }

    var weeklyGoalSessions = PomodoroStore.defaultWeeklyGoalSessions {
        didSet {
            let clampedSessions = Self.clampedWeeklyGoalSessions(weeklyGoalSessions)

            if weeklyGoalSessions != clampedSessions {
                weeklyGoalSessions = clampedSessions
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
    private(set) var activeTimerKind = PomodoroTimerKind.focus
    private(set) var activeStartedAt: Date?
    private(set) var activeEndAt: Date?
    private(set) var activePlannedMinutes: Int?
    private(set) var activePauseBeforeSeconds: TimeInterval?
    private(set) var pausedRemainingSeconds: TimeInterval?
    private(set) var notificationPermission = PomodoroNotificationPermission.unknown

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let persistenceKey: String
    @ObservationIgnored private let modelContainer: ModelContainer
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let nowProvider: () -> Date
    @ObservationIgnored private let notifier: any PomodoroNotifying
    @ObservationIgnored private let shouldScheduleTimer: Bool
    @ObservationIgnored private let runtime = PomodoroRuntime()
    @ObservationIgnored private var storedDay: Date
    @ObservationIgnored private var lastCompletedAt: Date?
    @ObservationIgnored private var isRestoringSnapshot = false
    @ObservationIgnored private var didRestoreWeeklyGoal = false

    var menuBarTitle: String {
        remainingClockText
    }

    var menuBarAccessibilityLabel: String {
        "TimerTomato, verbleibende Zeit \(remainingClockText)"
    }

    var menuBarSystemImage: String {
        if activeTimerKind == .breakTime, status != .idle {
            return "cup.and.saucer.fill"
        }

        switch status {
        case .idle:
            return "timer"
        case .running:
            return "timer.circle.fill"
        case .paused:
            return "pause.circle.fill"
        }
    }

    var notificationWarningText: String? {
        notificationPermission == .denied ? "Mitteilungen deaktiviert" : nil
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

    var averagePauseSecondsToday: TimeInterval? {
        let pauseDurations = sessions.compactMap(\.pauseBeforeSeconds)

        guard !pauseDurations.isEmpty else {
            return nil
        }

        return pauseDurations.reduce(0, +) / Double(pauseDurations.count)
    }

    var compactTodaySummaryText: String {
        guard sessionsCompletedToday > 0 else {
            return "0 min heute"
        }

        return "\(sessionsCompletedToday) · \(focusMinutesToday) min"
    }

    var todaySummaryText: String {
        PomodoroFormatters.todaySummaryText(
            sessions: sessionsCompletedToday,
            focusMinutes: focusMinutesToday,
            averagePauseSeconds: averagePauseSecondsToday
        )
    }

    var dailyGoalProgress: Double {
        guard dailyGoalSessions > 0 else {
            return 0
        }

        return min(Double(sessionsCompletedToday) / Double(dailyGoalSessions), 1)
    }

    var dailyGoalCountText: String {
        "\(min(sessionsCompletedToday, dailyGoalSessions))/\(dailyGoalSessions)"
    }

    var dailyGoalStatusText: String {
        if sessionsCompletedToday >= dailyGoalSessions {
            return "Tagesziel erreicht"
        }

        let remainingSessions = dailyGoalSessions - sessionsCompletedToday
        let unit = remainingSessions == 1 ? "Sitzung" : "Sitzungen"
        return "Noch \(remainingSessions) \(unit)"
    }

    var currentWeekSummary: PomodoroWeekSummary {
        weekSummary(containing: currentDate)
    }

    var weeklyGoalSuggestionSessions: Int {
        suggestedWeeklyGoalSessions()
    }

    var streakSummary: PomodoroStreakSummary {
        streakSummary(endingAt: currentDate)
    }

    var canStartBreak: Bool {
        status == .idle && lastCompletedAt != nil
    }

    var sessionHistory: [PomodoroSession] {
        fetchPersistedSessions()
    }

    init(
        defaults: UserDefaults = .standard,
        persistenceKey: String = "TimerTomato.PomodoroStore",
        modelContainer: ModelContainer = TimerTomatoModelContainer.makeDefault(),
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init,
        notifier: any PomodoroNotifying = UserNotificationScheduler(),
        shouldScheduleTimer: Bool = true
    ) {
        let initialDate = now()

        self.defaults = defaults
        self.persistenceKey = persistenceKey
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        self.calendar = calendar
        self.nowProvider = now
        self.notifier = notifier
        self.shouldScheduleTimer = shouldScheduleTimer
        self.currentDate = initialDate
        self.storedDay = calendar.startOfDay(for: initialDate)

        notifier.configureActionHandler { [weak self] action in
            self?.handleNotificationAction(action)
        }

        if shouldScheduleTimer {
            configureLifecycleObservers()
            refreshNotificationPermission()
        }

        restoreSnapshot()
        initializeWeeklyGoalIfNeeded()
        refreshLifecycleState(at: initialDate)
    }

    func start() {
        let startDate = nowProvider()
        refreshForToday(at: startDate)

        guard status == .idle else {
            return
        }

        startTimer(
            kind: .focus,
            minutes: selectedMinutes,
            startDate: startDate,
            pauseBeforeSeconds: lastCompletedAt.map { max(0, startDate.timeIntervalSince($0)) }
        )

        requestNotificationAuthorization()
    }

    func startBreak() {
        let startDate = nowProvider()
        refreshForToday(at: startDate)

        guard canStartBreak else {
            return
        }

        startTimer(
            kind: .breakTime,
            minutes: Self.breakMinutes,
            startDate: startDate,
            pauseBeforeSeconds: nil
        )

        requestNotificationAuthorization()
    }

    func pause() {
        updateCurrentDate()

        guard status == .running else {
            return
        }

        pausedRemainingSeconds = TimeInterval(remainingSeconds)
        status = .paused

        runtime.invalidateTimer()
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
        runtime.invalidateTimer()

        status = .idle
        activeTimerKind = .focus
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

    func selectPreset(minutes: Int) {
        selectedMinutes = minutes
    }

    func decreaseDailyGoalSessions() {
        dailyGoalSessions -= 1
    }

    func increaseDailyGoalSessions() {
        dailyGoalSessions += 1
    }

    func decreaseWeeklyGoalSessions() {
        weeklyGoalSessions -= 1
    }

    func increaseWeeklyGoalSessions() {
        weeklyGoalSessions += 1
    }

    func acceptWeeklyGoalSuggestion() {
        weeklyGoalSessions = weeklyGoalSuggestionSessions
    }

    func refreshForToday() {
        refreshForToday(at: nowProvider())
    }

    func refreshLifecycleState() {
        refreshLifecycleState(at: nowProvider())
    }

    func refreshNotificationPermission() {
        Task {
            notificationPermission = await notifier.authorizationStatus()
        }
    }

    func sessions(on date: Date) -> [PomodoroSession] {
        let dayStart = dayKey(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        return fetchSessions(startingAt: dayStart, before: dayEnd)
    }

    func historyDays(containing date: Date) -> [PomodoroHistoryDay] {
        let weekStart = startOfWeek(containing: date)

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }

            let daySessions = sessions(on: day)

            return PomodoroHistoryDay(
                date: day,
                sessions: daySessions,
                dailyGoalSessions: dailyGoalSessions
            )
        }
    }

    func weekSummary(containing date: Date) -> PomodoroWeekSummary {
        PomodoroWeekSummary(
            startDate: startOfWeek(containing: date),
            days: historyDays(containing: date),
            weeklyGoalSessions: weeklyGoalSessions
        )
    }

    func bestFocusDays(limit: Int) -> [PomodoroBestFocusDay] {
        Array(dailySummaries().prefix(limit))
    }

    func startOfWeek(containing date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    func dateByAddingWeeks(_ weeks: Int, to date: Date) -> Date {
        calendar.date(byAdding: .weekOfYear, value: weeks, to: date) ?? date
    }

    func isSameDay(_ firstDate: Date, _ secondDate: Date) -> Bool {
        calendar.isDate(firstDate, inSameDayAs: secondDate)
    }

    func dayTitle(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Heute"
        }

        return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    func weekTitle(containing date: Date) -> String {
        let days = historyDays(containing: date)

        guard let firstDate = days.first?.date, let lastDate = days.last?.date else {
            return "Diese Woche"
        }

        let first = firstDate.formatted(.dateTime.day().month(.abbreviated))
        let last = lastDate.formatted(.dateTime.day().month(.abbreviated))
        return "\(first) - \(last)"
    }

    func tick() {
        updateCurrentDate()

        guard status == .running, remainingSeconds <= 0 else {
            return
        }

        completeActiveTimer(at: activeEndAt ?? currentDate)
    }

    static func clampedMinutes(_ minutes: Int) -> Int {
        min(max(minutes, minimumMinutes), maximumMinutes)
    }

    static func clampedDailyGoalSessions(_ sessions: Int) -> Int {
        min(max(sessions, minimumDailyGoalSessions), maximumDailyGoalSessions)
    }

    static func clampedWeeklyGoalSessions(_ sessions: Int) -> Int {
        min(max(sessions, minimumWeeklyGoalSessions), maximumWeeklyGoalSessions)
    }

    private func startTimer(
        kind: PomodoroTimerKind,
        minutes: Int,
        startDate: Date,
        pauseBeforeSeconds: TimeInterval?
    ) {
        let durationSeconds = TimeInterval(minutes * 60)

        activeTimerKind = kind
        activeStartedAt = startDate
        activeEndAt = startDate.addingTimeInterval(durationSeconds)
        activePlannedMinutes = minutes
        activePauseBeforeSeconds = pauseBeforeSeconds
        pausedRemainingSeconds = nil
        status = .running
        currentDate = startDate

        persistSnapshot()
        scheduleTimer()
    }

    private func refreshForToday(at date: Date) {
        currentDate = date
        sessions = sessions(on: date)
        lastCompletedAt = sessions.last?.endedAt

        guard !calendar.isDate(storedDay, inSameDayAs: date) else {
            return
        }

        storedDay = calendar.startOfDay(for: date)
        persistSnapshot()
    }

    private func updateCurrentDate() {
        currentDate = nowProvider()
    }

    private func fetchPersistedSessions() -> [PomodoroSession] {
        var descriptor = FetchDescriptor<PomodoroSessionRecord>(
            sortBy: [SortDescriptor(\.startedAt)]
        )
        descriptor.relationshipKeyPathsForPrefetching = []

        do {
            return try modelContext.fetch(descriptor).map(PomodoroSession.init(record:))
        } catch {
            assertionFailure("Could not fetch Pomodoro sessions: \(error)")
            return []
        }
    }

    private func fetchSessions(startingAt startDate: Date, before endDate: Date) -> [PomodoroSession] {
        let predicate = #Predicate<PomodoroSessionRecord> { session in
            session.startedAt >= startDate && session.startedAt < endDate
        }
        var descriptor = FetchDescriptor<PomodoroSessionRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startedAt)]
        )
        descriptor.relationshipKeyPathsForPrefetching = []

        do {
            return try modelContext.fetch(descriptor).map(PomodoroSession.init(record:))
        } catch {
            assertionFailure("Could not fetch Pomodoro sessions for day: \(error)")
            return []
        }
    }

    private func persistSession(_ session: PomodoroSession) {
        modelContext.insert(PomodoroSessionRecord(session: session))

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Could not save Pomodoro session: \(error)")
        }
    }

    private func migrateLegacySessionsIfNeeded(_ legacySessions: [PomodoroSession]) -> Bool {
        guard !legacySessions.isEmpty else {
            return true
        }

        let existingIDs = Set(fetchPersistedSessions().map(\.id))

        for session in legacySessions where !existingIDs.contains(session.id) {
            modelContext.insert(PomodoroSessionRecord(session: session))
        }

        do {
            try modelContext.save()
            return true
        } catch {
            assertionFailure("Could not migrate legacy Pomodoro sessions: \(error)")
            return false
        }
    }

    private func dayKey(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func completeActiveTimer(at completionDate: Date) {
        switch activeTimerKind {
        case .focus:
            completeFocusSession(at: completionDate)
        case .breakTime:
            completeBreak(at: completionDate)
        }
    }

    private func completeFocusSession(at completionDate: Date) {
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

        persistSession(session)
        sessions = sessions(on: endedAt)
        lastCompletedAt = endedAt
        status = .idle
        activeTimerKind = .focus
        activeStartedAt = nil
        activeEndAt = nil
        activePlannedMinutes = nil
        activePauseBeforeSeconds = nil
        pausedRemainingSeconds = nil
        currentDate = endedAt

        runtime.invalidateTimer()

        persistSnapshot()

        Task {
            await notifier.notifySessionCompleted(plannedMinutes: plannedMinutes)
        }
    }

    private func completeBreak(at completionDate: Date) {
        guard let startedAt = activeStartedAt else {
            reset()
            return
        }

        let plannedMinutes = activePlannedMinutes ?? Self.breakMinutes
        let endedAt = max(completionDate, startedAt)

        status = .idle
        activeTimerKind = .focus
        activeStartedAt = nil
        activeEndAt = nil
        activePlannedMinutes = nil
        activePauseBeforeSeconds = nil
        pausedRemainingSeconds = nil
        currentDate = endedAt

        runtime.invalidateTimer()

        persistSnapshot()

        Task {
            await notifier.notifyBreakCompleted(plannedMinutes: plannedMinutes)
        }
    }

    private func scheduleTimer() {
        guard shouldScheduleTimer else {
            return
        }

        runtime.scheduleTimer { [weak self] in
            self?.tick()
        }
    }

    private func handleNotificationAction(_ action: PomodoroNotificationAction) {
        switch action {
        case .done:
            refreshForToday()
        case .startBreak:
            startBreak()
        case .startNextFocus:
            start()
        }
    }

    private func restoreSnapshot() {
        guard
            let data = defaults.data(forKey: persistenceKey),
            let snapshot = try? JSONDecoder().decode(PomodoroSnapshot.self, from: data)
        else {
            return
        }

        let legacySessions = snapshot.sessionHistory ?? snapshot.sessions ?? []
        let shouldMigrateLegacySessions = !(snapshot.sessionHistoryMigratedToSwiftData ?? false)

        isRestoringSnapshot = true
        selectedMinutes = Self.clampedMinutes(snapshot.selectedMinutes)
        dailyGoalSessions = Self.clampedDailyGoalSessions(snapshot.dailyGoalSessions ?? Self.defaultDailyGoalSessions)
        weeklyGoalSessions = Self.clampedWeeklyGoalSessions(snapshot.weeklyGoalSessions ?? Self.defaultWeeklyGoalSessions)
        didRestoreWeeklyGoal = snapshot.weeklyGoalSessions != nil
        status = snapshot.status
        activeTimerKind = snapshot.activeTimerKind ?? .focus
        storedDay = snapshot.storedDay
        lastCompletedAt = snapshot.lastCompletedAt
        activeStartedAt = snapshot.activeStartedAt
        activeEndAt = snapshot.activeEndAt
        activePlannedMinutes = snapshot.activePlannedMinutes
        activePauseBeforeSeconds = snapshot.activePauseBeforeSeconds
        pausedRemainingSeconds = snapshot.pausedRemainingSeconds
        isRestoringSnapshot = false

        if shouldMigrateLegacySessions, migrateLegacySessionsIfNeeded(legacySessions) {
            persistSnapshot()
        }
    }

    private func persistSnapshot() {
        let snapshot = PomodoroSnapshot(
            selectedMinutes: selectedMinutes,
            dailyGoalSessions: dailyGoalSessions,
            weeklyGoalSessions: weeklyGoalSessions,
            status: status,
            activeTimerKind: activeTimerKind,
            storedDay: storedDay,
            sessions: nil,
            sessionHistory: nil,
            sessionHistoryMigratedToSwiftData: true,
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

    private func initializeWeeklyGoalIfNeeded() {
        guard !didRestoreWeeklyGoal else {
            return
        }

        didRestoreWeeklyGoal = true
        weeklyGoalSessions = weeklyGoalSuggestionSessions
    }

    private func suggestedWeeklyGoalSessions() -> Int {
        let currentWeekStart = startOfWeek(containing: currentDate)
        let recentCompletedWeekCounts = (1...4).compactMap { offset -> Int? in
            guard
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart),
                let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)
            else {
                return nil
            }

            let sessionCount = fetchSessions(startingAt: weekStart, before: weekEnd).count
            return sessionCount > 0 ? sessionCount : nil
        }

        guard !recentCompletedWeekCounts.isEmpty else {
            return Self.clampedWeeklyGoalSessions(dailyGoalSessions * 5)
        }

        let totalSessions = recentCompletedWeekCounts.reduce(0, +)
        let averageSessions = Double(totalSessions) / Double(recentCompletedWeekCounts.count)
        return Self.clampedWeeklyGoalSessions(Int(ceil(averageSessions * 1.10)))
    }

    private func streakSummary(endingAt date: Date) -> PomodoroStreakSummary {
        let goalDays = Set(
            dailySummaries()
                .filter { $0.sessionCount >= dailyGoalSessions }
                .map(\.date)
        )
        let today = dayKey(for: date)
        let currentAnchor = goalDays.contains(today) ? today : previousDay(before: today)

        var currentDays = 0
        var cursor = currentAnchor

        while goalDays.contains(cursor) {
            currentDays += 1
            cursor = previousDay(before: cursor)
        }

        var bestDays = 0
        var runningDays = 0
        var previousGoalDay: Date?

        for goalDay in goalDays.sorted() {
            if let previousGoalDay, isSameDay(goalDay, nextDay(after: previousGoalDay)) {
                runningDays += 1
            } else {
                runningDays = 1
            }

            bestDays = max(bestDays, runningDays)
            previousGoalDay = goalDay
        }

        return PomodoroStreakSummary(
            currentDays: currentDays,
            bestDays: bestDays,
            latestGoalDate: currentDays > 0 ? currentAnchor : nil
        )
    }

    private func dailySummaries() -> [PomodoroBestFocusDay] {
        Dictionary(grouping: fetchPersistedSessions()) { session in
            dayKey(for: session.startedAt)
        }
        .map { day, sessions in
            PomodoroBestFocusDay(
                date: day,
                sessionCount: sessions.count,
                focusMinutes: sessions.reduce(0) { result, session in
                    result + session.plannedMinutes
                }
            )
        }
        .filter { $0.sessionCount > 0 }
        .sorted { first, second in
            if first.focusMinutes != second.focusMinutes {
                return first.focusMinutes > second.focusMinutes
            }

            if first.sessionCount != second.sessionCount {
                return first.sessionCount > second.sessionCount
            }

            return first.date > second.date
        }
    }

    private func previousDay(before date: Date) -> Date {
        calendar.date(byAdding: .day, value: -1, to: date) ?? date
    }

    private func nextDay(after date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }

    private func refreshLifecycleState(at date: Date) {
        currentDate = date

        if status == .running, remainingSeconds <= 0 {
            completeActiveTimer(at: activeEndAt ?? date)
            refreshForToday(at: date)
            return
        }

        refreshForToday(at: date)

        if status == .running {
            scheduleTimer()
        }
    }

    private func configureLifecycleObservers() {
        runtime.observeWake { [weak self] in
            self?.refreshLifecycleState()
            self?.refreshNotificationPermission()
        }
    }

    private func requestNotificationAuthorization() {
        Task {
            notificationPermission = await notifier.requestAuthorizationIfNeeded()
        }
    }
}

nonisolated private final class PomodoroRuntime {
    private var timer: Timer?
    private var wakeObserver: NSObjectProtocol?

    deinit {
        timer?.invalidate()

        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
        }
    }

    func scheduleTimer(tick: @escaping @MainActor () -> Void) {
        timer?.invalidate()

        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            MainActor.assumeIsolated {
                tick()
            }
        }
        timer.tolerance = 0.2
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    func observeWake(_ handler: @escaping @MainActor () -> Void) {
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                handler()
            }
        }
    }
}
