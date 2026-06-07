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

    @Test func durationStepSelectionPersists() async {
        let defaults = makeDefaults()
        let store = makeStore(defaults: defaults)

        store.decreaseSelectedMinutes()
        store.decreaseSelectedMinutes()
        store.decreaseSelectedMinutes()

        #expect(store.selectedMinutes == 10)

        let restored = makeStore(defaults: defaults)
        #expect(restored.selectedMinutes == 10)
    }

    @Test func durationPresetSelectionPersists() async {
        let defaults = makeDefaults()
        let store = makeStore(defaults: defaults)

        store.selectDurationPreset(minutes: 10)

        #expect(store.selectedMinutes == 10)

        let restored = makeStore(defaults: defaults)
        #expect(restored.selectedMinutes == 10)
    }

    @Test func focusIntentSuggestionsUseConcreteFocusWinsDefaults() async {
        #expect(PomodoroStore.focusIntentSuggestions == [
            "Entwurf schreiben",
            "Bug fixen",
            "Inbox leeren",
            "Lernen"
        ])
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
        #expect(store.sessions[0].isPendingOutcome)
        #expect(store.pendingOutcomeSession?.id == store.sessions[0].id)
        #expect(store.focusWinsToday == 0)
        #expect(notifier.completedSessionMinutes == [25])

        store.completePendingOutcome(.completed)

        #expect(store.pendingOutcomeSession == nil)
        #expect(store.focusWinsToday == 1)
        #expect(store.sessions[0].outcome == .completed)
    }

    @Test func intentAndPendingOutcomeRestoreUntilSelection() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.pendingFocusIntent = "  Bug fixen  "
        store.start()

        #expect(store.pendingFocusIntent.isEmpty)
        #expect(store.activeFocusIntentText == "Bug fixen")

        now = date(hour: 9, minute: 25)
        store.tick()

        let pendingSessionID = store.pendingOutcomeSession?.id

        #expect(pendingSessionID != nil)
        #expect(store.sessions[0].intentTitle == "Bug fixen")
        #expect(store.sessions[0].isPendingOutcome)
        #expect(store.focusWinsToday == 0)

        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        #expect(restored.pendingOutcomeSession?.id == pendingSessionID)
        #expect(restored.sessions[0].intentTitle == "Bug fixen")

        restored.completePendingOutcome(.progressed)

        #expect(restored.pendingOutcomeSession == nil)
        #expect(restored.focusWinsToday == 1)
        #expect(restored.sessions[0].outcome == .progressed)
    }

    @Test func learningChecklistStartsWithDefaultsAndResetsPerSession() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.pendingFocusIntent = "Lernen"
        store.start()

        #expect(store.activeFocusIntentText == "Lernen")
        #expect(store.pendingFocusIntent.isEmpty)
        #expect(store.activeFocusChecklist?.goal == "Lernen")
        #expect(store.activeFocusChecklist?.reminderMode == .normal)
        #expect(store.activeFocusChecklist?.items.map(\.title) == PomodoroChecklist.learningDefaultTitles)
        #expect(
            store.activeFocusChecklist?.items.map(\.reminderMinuteOffset)
                == PomodoroChecklist.learningDefaultReminderMinuteOffsets
        )
        #expect(store.activeFocusChecklist?.items.allSatisfy { !$0.isCompleted } == true)

        if let firstItemID = store.activeFocusChecklist?.items.first?.id {
            store.setChecklistItemCompleted(firstItemID, isCompleted: true)
        }

        #expect(store.activeFocusChecklist?.items.first?.isCompleted == true)

        now = date(hour: 9, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)
        now = date(hour: 9, minute: 26)
        store.pendingFocusIntent = "Lernen"
        store.start()

        #expect(store.activeFocusChecklist?.items.map(\.title) == PomodoroChecklist.learningDefaultTitles)
        #expect(
            store.activeFocusChecklist?.items.map(\.reminderMinuteOffset)
                == PomodoroChecklist.learningDefaultReminderMinuteOffsets
        )
        #expect(store.activeFocusChecklist?.items.allSatisfy { !$0.isCompleted } == true)
    }

    @Test func checklistTemplateEditsPersistByGoal() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        let now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        let firstItemID = PomodoroChecklist.defaultTemplate(for: "Lernen").items[0].id
        store.updateChecklistItem(firstItemID, title: "  Skript öffnen  ", in: " Lernen ")
        store.updateChecklistItem(firstItemID, reminderMinuteOffset: 4, in: " Lernen ")
        store.addChecklistItem(to: "Lernen")

        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })
        let restoredTemplate = restored.checklistTemplate(for: "Lernen")

        #expect(restoredTemplate.items.first?.title == "Skript öffnen")
        #expect(restoredTemplate.items.first?.reminderMinuteOffset == 4)
        #expect(restoredTemplate.items.last?.title == "Neuer Schritt")
        #expect(restoredTemplate.items.allSatisfy { !$0.isCompleted })
    }

    @Test func checklistReminderModePersistsByGoalAndDefaultsToNormal() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        let now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        #expect(store.checklistTemplate(for: "Lernen").reminderMode == .normal)

        store.setChecklistReminderMode(.quiet, for: " Lernen ")

        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })
        #expect(restored.checklistTemplate(for: "Lernen").reminderMode == .quiet)

        let oldChecklistData = """
        {"goal":"Lernen","items":[]}
        """.data(using: .utf8)!
        let decodedChecklist = try? JSONDecoder().decode(PomodoroChecklist.self, from: oldChecklistData)

        #expect(decodedChecklist?.reminderMode == .normal)
    }

    @Test func checklistRemindersAreScheduledForLearningFocus() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        let store = makeStore(
            defaults: defaults,
            now: { date(hour: 9, minute: 0) },
            notifier: notifier
        )

        store.pendingFocusIntent = "Lernen"
        store.start()
        await drainNotificationTasks()

        #expect(notifier.scheduledChecklistReminders.map(\.title) == PomodoroChecklist.learningDefaultTitles)
        #expect(notifier.scheduledChecklistReminders.map(\.delaySeconds) == [1, 60, 180, 360])
        #expect(notifier.scheduledChecklistReminders.allSatisfy { $0.playsSound })
    }

    @Test func checklistReminderModesControlSchedulingAndSound() async {
        let quietNotifier = TestPomodoroNotifier()
        let quietStore = makeStore(
            defaults: makeDefaults(),
            now: { date(hour: 9, minute: 0) },
            notifier: quietNotifier
        )

        quietStore.setChecklistReminderMode(.quiet, for: "Lernen")
        quietStore.pendingFocusIntent = "Lernen"
        quietStore.start()
        await drainNotificationTasks()

        #expect(quietNotifier.scheduledChecklistReminders.count == PomodoroChecklist.learningDefaultTitles.count)
        #expect(quietNotifier.scheduledChecklistReminders.allSatisfy { !$0.playsSound })

        let offNotifier = TestPomodoroNotifier()
        let offStore = makeStore(
            defaults: makeDefaults(),
            now: { date(hour: 9, minute: 0) },
            notifier: offNotifier
        )

        offStore.setChecklistReminderMode(.off, for: "Lernen")
        offStore.pendingFocusIntent = "Lernen"
        offStore.start()
        await drainNotificationTasks()

        #expect(offNotifier.scheduledChecklistReminders.isEmpty)
    }

    @Test func checklistRemindersCancelOnPauseAndResumeRemainingItems() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.pendingFocusIntent = "Lernen"
        store.start()
        await drainNotificationTasks()

        now = date(hour: 9, minute: 2)
        store.pause()

        #expect(notifier.canceledChecklistReminderIdentifiers.count == 4)

        now = date(hour: 9, minute: 5)
        store.resume()
        await drainNotificationTasks()

        let resumedReminders = Array(notifier.scheduledChecklistReminders.dropFirst(4))
        #expect(resumedReminders.map(\.title) == Array(PomodoroChecklist.learningDefaultTitles.dropFirst(2)))
        #expect(resumedReminders.map(\.delaySeconds) == [60, 240])
        #expect(resumedReminders.allSatisfy { $0.playsSound })
    }

    @Test func activeChecklistCompletionRestoresDuringRunningFocus() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.pendingFocusIntent = "Lernen"
        store.start()

        if let firstItemID = store.activeFocusChecklist?.items.first?.id {
            store.setChecklistItemCompleted(firstItemID, isCompleted: true)
        }

        now = date(hour: 9, minute: 5)

        let restored = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { now }
        )

        #expect(restored.status == .running)
        #expect(restored.activeFocusChecklist?.goal == "Lernen")
        #expect(restored.activeFocusChecklist?.items.first?.isCompleted == true)
        #expect(restored.activeFocusChecklist?.items.dropFirst().allSatisfy { !$0.isCompleted } == true)
    }

    @Test func activeChecklistCueShowsNextOpenStep() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Lernen"
        store.start()

        #expect(store.activeChecklistCue?.title == "Buch öffnen")
        #expect(store.activeChecklistCue?.timeText == "Jetzt")
        #expect(store.activeChecklistCue?.isDue == true)

        if let firstItemID = store.activeFocusChecklist?.items.first?.id {
            store.setChecklistItemCompleted(firstItemID, isCompleted: true)
        }

        #expect(store.activeChecklistCue?.title == "Inhalt lesen")
        #expect(store.activeChecklistCue?.timeText == "In 1 min")
        #expect(store.activeChecklistCue?.isDue == false)

        now = date(hour: 9, minute: 1)
        store.tick()

        #expect(store.activeChecklistCue?.title == "Inhalt lesen")
        #expect(store.activeChecklistCue?.timeText == "Jetzt")
        #expect(store.activeChecklistCue?.isDue == true)
    }

    @Test func activeFocusIntentChangeTracksNetFocusSegments() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        #expect(store.activeFocusIntentText == "Bug fixen")
        #expect(store.activeFocusSegments.isEmpty)
        #expect(store.activeFocusSegmentStartedFocusSeconds == 0)

        now = date(hour: 9, minute: 10)
        store.changeActiveFocusIntent("Lernen")

        #expect(store.activeFocusIntentText == "Lernen")
        #expect(store.activeFocusSegments.map(\.intent) == ["Bug fixen"])
        #expect(store.activeFocusSegments.map(\.focusSeconds) == [600])

        now = date(hour: 9, minute: 25)
        store.tick()

        #expect(store.sessions[0].focusSegments.map(\.intent) == ["Bug fixen", "Lernen"])
        #expect(store.sessions[0].focusSegments.map(\.focusSeconds) == [600, 900])
    }

    @Test func activeFocusIntentChangeWhilePausedDoesNotCountPauseTime() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 5)
        store.pause()

        now = date(hour: 9, minute: 10)
        store.changeActiveFocusIntent("Lernen")

        #expect(store.activeFocusSegments.map(\.focusSeconds) == [300])

        now = date(hour: 9, minute: 15)
        store.resume()

        now = date(hour: 9, minute: 35)
        store.tick()

        #expect(store.sessions[0].focusSegments.map(\.intent) == ["Bug fixen", "Lernen"])
        #expect(store.sessions[0].focusSegments.map(\.focusSeconds) == [300, 1_200])
    }

    @Test func topicSummariesAggregateRepeatedTopics() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 5)
        store.changeActiveFocusIntent("Lernen")

        now = date(hour: 9, minute: 15)
        store.changeActiveFocusIntent("Bug fixen")

        now = date(hour: 9, minute: 25)
        store.tick()

        let summaries = store.topicSummaries(on: date(hour: 9, minute: 0))

        #expect(summaries.map(\.intent) == ["Bug fixen", "Lernen"])
        #expect(summaries.map(\.focusSeconds) == [900, 600])
        #expect(summaries.map(\.sessionCount) == [1, 1])
        #expect(store.sessions[0].topicCount == 2)
    }

    @Test func changingToSameFocusIntentIsNoop() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 5)
        store.changeActiveFocusIntent("  Bug fixen  ")

        #expect(store.activeFocusSegments.isEmpty)
        #expect(store.activeFocusIntentText == "Bug fixen")

        now = date(hour: 9, minute: 25)
        store.tick()

        #expect(store.sessions[0].focusSegments.map(\.intent) == ["Bug fixen"])
        #expect(store.sessions[0].focusSegments.map(\.focusSeconds) == [1_500])
    }

    @Test func resetClearsActiveFocusSegments() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 5)
        store.changeActiveFocusIntent("Lernen")
        store.reset()

        #expect(store.status == .idle)
        #expect(store.activeFocusIntentText == nil)
        #expect(store.activeFocusSegments.isEmpty)
        #expect(store.activeFocusSegmentStartedFocusSeconds == nil)
    }

    @Test func activeFocusSegmentsRestoreAndComplete() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 5)
        store.changeActiveFocusIntent("Lernen")

        now = date(hour: 9, minute: 8)
        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        #expect(restored.status == .running)
        #expect(restored.activeFocusIntentText == "Lernen")
        #expect(restored.activeFocusSegments.map(\.intent) == ["Bug fixen"])
        #expect(restored.activeFocusSegments.map(\.focusSeconds) == [300])
        #expect(restored.activeFocusSegmentStartedFocusSeconds == 300)

        now = date(hour: 9, minute: 25)
        restored.tick()

        #expect(restored.sessions[0].focusSegments.map(\.intent) == ["Bug fixen", "Lernen"])
        #expect(restored.sessions[0].focusSegments.map(\.focusSeconds) == [300, 1_200])
    }

    @Test func persistedFocusSegmentsRestoreAcrossStoreInstances() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 10)
        store.changeActiveFocusIntent("Lernen")

        now = date(hour: 9, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        #expect(restored.sessions[0].focusSegments.map(\.intent) == ["Bug fixen", "Lernen"])
        #expect(restored.sessions[0].focusSegments.map(\.focusSeconds) == [600, 900])
    }

    @Test func legacySessionsWithoutPersistedSegmentsFallbackToIntent() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        let context = modelContainer.mainContext

        context.insert(
            PomodoroSessionRecord(
                startedAt: date(hour: 9, minute: 0),
                endedAt: date(hour: 9, minute: 25),
                plannedMinutes: 25,
                pauseBeforeSeconds: nil,
                intent: "Bug fixen",
                focusSegmentsData: nil
            )
        )

        do {
            try context.save()
        } catch {
            fatalError("Could not seed legacy session record: \(error)")
        }

        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { date(hour: 12, minute: 0) })
        let summaries = store.topicSummaries(on: date(hour: 9, minute: 0))

        #expect(store.sessions[0].focusSegments.map(\.intent) == ["Bug fixen"])
        #expect(store.sessions[0].focusSegments.map(\.focusSeconds) == [1_500])
        #expect(summaries.map(\.intent) == ["Bug fixen"])
        #expect(summaries.map(\.focusSeconds) == [1_500])
    }

    @Test func segmentedSessionStillCountsAsSingleGoalSession() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.dailyGoalSessions = 1
        store.weeklyGoalSessions = 1
        store.pendingFocusIntent = "Bug fixen"
        store.start()

        now = date(hour: 9, minute: 10)
        store.changeActiveFocusIntent("Lernen")

        now = date(hour: 9, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

        #expect(store.sessionsCompletedToday == 1)
        #expect(store.focusWinsToday == 1)
        #expect(store.dailyGoalCountText == "1/1")
        #expect(store.currentWeekSummary.goalCountText == "1/1")
    }

    @Test func focusWinsTreatOutcomesAndLegacySessionsCorrectly() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            [
                session(day: 1, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 1, startHour: 10, startMinute: 0, outcome: .progressed, isOutcomeTracked: true),
                session(day: 1, startHour: 11, startMinute: 0, outcome: .blocked, isOutcomeTracked: true),
                session(day: 1, startHour: 12, startMinute: 0)
            ],
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 1, hour: 13, minute: 0) }
        )

        store.dailyGoalSessions = 3
        store.weeklyGoalSessions = 3

        #expect(store.sessionsCompletedToday == 4)
        #expect(store.focusWinsToday == 3)
        #expect(store.dailyGoalProgress == 1)
        #expect(store.dailyGoalCountText == "3/3")

        let summary = store.weekSummary(containing: date(day: 1, hour: 13, minute: 0))
        #expect(summary.sessionCount == 4)
        #expect(summary.focusWinCount == 3)
        #expect(summary.goalProgress == 1)
        #expect(summary.goalCountText == "3/3")
    }

    @Test func completionFeedbackSummarizesCompletedAndProgressedFocusWins() async {
        let completedContainer = makeModelContainer()
        let completedSession = session(day: 18, startHour: 9, startMinute: 0, intent: "Bug fixen", outcome: .completed, isOutcomeTracked: true)
        seedSessions([completedSession], in: completedContainer)
        let completedStore = makeStore(
            defaults: makeDefaults(),
            modelContainer: completedContainer,
            now: { date(day: 18, hour: 10, minute: 0) }
        )
        completedStore.dailyGoalSessions = 1
        completedStore.weeklyGoalSessions = 4

        let completedFeedback = completedStore.completionFeedback(for: completedSession, outcome: .completed)

        #expect(completedFeedback.kind == .focusWin)
        #expect(completedFeedback.title == "+1 Session")
        #expect(completedFeedback.detail == "Heute 1/1 · Woche 1/4")
        #expect(completedFeedback.continuationIntent == nil)
        #expect(completedFeedback.offersRescueAction == false)

        let progressedContainer = makeModelContainer()
        let progressedSession = session(day: 18, startHour: 11, startMinute: 0, intent: "Lernen", outcome: .progressed, isOutcomeTracked: true)
        seedSessions([progressedSession], in: progressedContainer)
        let progressedStore = makeStore(
            defaults: makeDefaults(),
            modelContainer: progressedContainer,
            now: { date(day: 18, hour: 12, minute: 0) }
        )
        progressedStore.dailyGoalSessions = 1
        progressedStore.weeklyGoalSessions = 4

        let progressedFeedback = progressedStore.completionFeedback(for: progressedSession, outcome: .progressed)

        #expect(progressedFeedback.kind == .focusWin)
        #expect(progressedFeedback.title == "+1 Session")
        #expect(progressedFeedback.detail == "Heute 1/1 · Woche 1/4")
        #expect(progressedFeedback.continuationIntent == "Lernen")
        #expect(progressedFeedback.offersRescueAction == false)
    }

    @Test func continueFocusStartsNextSessionWithIntent() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.continueFocus(with: "  Lernen  ")

        #expect(store.status == .running)
        #expect(store.activeFocusIntentText == "Lernen")
        #expect(store.pendingFocusIntent.isEmpty)

        now = date(hour: 9, minute: 25)
        store.tick()
        #expect(store.pendingOutcomeSession?.intentTitle == "Lernen")
    }

    @Test func rescueSessionRestoresAndSavesOutcome() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.startRescueFocus()

        #expect(store.status == .running)
        #expect(store.activePlannedMinutes == 10)
        #expect(store.activeFocusIntentText == "Kurz dranbleiben")
        #expect(store.activeIsRescueSession)

        now = date(hour: 9, minute: 5)
        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        #expect(restored.status == .running)
        #expect(restored.activeIsRescueSession)
        #expect(restored.remainingSeconds == 300)

        now = date(hour: 9, minute: 10)
        restored.tick()

        #expect(restored.pendingOutcomeSession?.isRescue == true)
        #expect(restored.pendingOutcomeSession?.plannedMinutes == 10)
        #expect(restored.pendingOutcomeSession?.intentTitle == "Kurz dranbleiben")

        restored.completePendingOutcome(.completed)

        #expect(restored.pendingOutcomeSession == nil)
        #expect(restored.sessionHistory.count == 1)
        #expect(restored.sessionHistory[0].isRescue)
        #expect(restored.sessionHistory[0].outcome == .completed)
    }

    @Test func rescueCountsForMomentumButNotGoalsOrStreak() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.dailyGoalSessions = 1
        store.weeklyGoalSessions = 1
        store.startRescueFocus()
        now = date(hour: 9, minute: 10)
        store.tick()
        store.completePendingOutcome(.completed)

        let summary = store.weekSummary(containing: date(hour: 12, minute: 0))

        #expect(store.focusWinsToday == 0)
        #expect(store.dailyGoalProgress == 0)
        #expect(summary.focusWinCount == 0)
        #expect(summary.goalProgress == 0)
        #expect(store.streakSummary.currentDays == 0)
        #expect(store.momentumSummary.activeDayCount == 1)
        #expect(store.momentumSummary.hasActivityToday)
    }

    @Test func completionFeedbackSummarizesRescueAsMomentum() async {
        let modelContainer = makeModelContainer()
        let rescueSession = session(
            day: 18,
            startHour: 9,
            startMinute: 0,
            durationMinutes: PomodoroStore.rescueMinutes,
            outcome: .completed,
            isOutcomeTracked: true,
            isRescue: true
        )
        seedSessions([rescueSession], in: modelContainer)
        let store = makeStore(
            defaults: makeDefaults(),
            modelContainer: modelContainer,
            now: { date(day: 18, hour: 10, minute: 0) }
        )
        store.weeklyGoalSessions = 4

        let feedback = store.completionFeedback(for: rescueSession, outcome: .completed)

        #expect(feedback.kind == .momentum)
        #expect(feedback.title == "Drangeblieben")
        #expect(feedback.detail == "10-min Reset · Woche 0/4")
        #expect(feedback.offersRescueAction == false)
    }

    @Test func momentumCountsLastSevenActiveDaysAndIgnoresPendingOutcomes() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            [
                session(day: 17, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 18, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 19, startHour: 9, startMinute: 0, outcome: .blocked, isOutcomeTracked: true),
                session(day: 20, startHour: 9, startMinute: 0),
                session(day: 21, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true, isRescue: true),
                session(day: 22, startHour: 9, startMinute: 0, outcome: nil, isOutcomeTracked: true)
            ],
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 24, hour: 12, minute: 0) }
        )

        let summary = store.momentumSummary

        #expect(summary.days.map(\.date) == (18...24).map { date(day: $0, hour: 0, minute: 0) })
        #expect(summary.days.map(\.hasActivity) == [true, true, true, true, false, false, false])
        #expect(summary.activeDayCount == 4)
        #expect(summary.hasActivityToday == false)
    }

    @Test func weeklyQuestStatusTextCoversOnCourseOpenAndAchieved() async {
        let onCourseContainer = makeModelContainer()
        seedSessions(makeSessions(day: 18, count: 1) + makeSessions(day: 19, count: 1) + makeSessions(day: 20, count: 1), in: onCourseContainer)
        let onCourse = makeStore(
            defaults: makeDefaults(),
            modelContainer: onCourseContainer,
            now: { date(day: 20, hour: 12, minute: 0) }
        )
        onCourse.weeklyGoalSessions = 6

        let openContainer = makeModelContainer()
        seedSessions(makeSessions(day: 18, count: 1), in: openContainer)
        let open = makeStore(
            defaults: makeDefaults(),
            modelContainer: openContainer,
            now: { date(day: 20, hour: 12, minute: 0) }
        )
        open.weeklyGoalSessions = 6

        let achievedContainer = makeModelContainer()
        seedSessions(makeSessions(day: 18, count: 6), in: achievedContainer)
        let achieved = makeStore(
            defaults: makeDefaults(),
            modelContainer: achievedContainer,
            now: { date(day: 20, hour: 12, minute: 0) }
        )
        achieved.weeklyGoalSessions = 6

        #expect(onCourse.weeklyQuestStatusText(containing: date(day: 20, hour: 12, minute: 0)) == "Du bist auf Kurs")
        #expect(open.weeklyQuestStatusText(containing: date(day: 20, hour: 12, minute: 0)) == "Noch 5 Sessions bis zur starken Woche")
        #expect(achieved.weeklyQuestStatusText(containing: date(day: 20, hour: 12, minute: 0)) == "Starke Woche geschafft")
    }

    @Test func blockerDetailsPersistWithOutcome() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()
        store.completePendingOutcome(
            .blocked,
            blockerReason: .tooLarge,
            blockerNextStep: "  Aufgabe in einen ersten Absatz schneiden  "
        )

        let restored = makeStore(defaults: defaults, modelContainer: modelContainer, now: { now })
        let savedSession = restored.sessionHistory[0]

        #expect(savedSession.outcome == .blocked)
        #expect(savedSession.blockerReason == .tooLarge)
        #expect(savedSession.blockerNextStep == "Aufgabe in einen ersten Absatz schneiden")
    }

    @Test func completionFeedbackSummarizesBlockerAndOffersReset() async {
        let modelContainer = makeModelContainer()
        let blockedSession = session(
            day: 18,
            startHour: 9,
            startMinute: 0,
            outcome: .blocked,
            isOutcomeTracked: true,
            blockerReason: .tooLarge,
            blockerNextStep: "Ticket schneiden"
        )
        seedSessions([blockedSession], in: modelContainer)
        let store = makeStore(
            defaults: makeDefaults(),
            modelContainer: modelContainer,
            now: { date(day: 18, hour: 10, minute: 0) }
        )

        let feedback = store.completionFeedback(for: blockedSession, outcome: .blocked)

        #expect(feedback.kind == .blocked)
        #expect(feedback.title == "Blockade notiert")
        #expect(feedback.detail == "1x blockiert · Zu groß")
        #expect(feedback.offersRescueAction)
    }

    @Test func blockerSummaryCountsCurrentWeekAndSortsMostCommonReason() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            [
                session(day: 11, startHour: 9, startMinute: 0, outcome: .blocked, isOutcomeTracked: true, blockerReason: .tooLarge),
                session(day: 18, startHour: 9, startMinute: 0, outcome: .blocked, isOutcomeTracked: true, blockerReason: .unclearNextStep, blockerNextStep: "Ticket teilen"),
                session(day: 19, startHour: 9, startMinute: 0, outcome: .blocked, isOutcomeTracked: true, blockerReason: .waiting, blockerNextStep: "Antwort von Lisa prüfen"),
                session(day: 20, startHour: 9, startMinute: 0, outcome: .blocked, isOutcomeTracked: true, blockerReason: .unclearNextStep),
                session(day: 20, startHour: 10, startMinute: 0, outcome: .progressed, isOutcomeTracked: true)
            ],
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 20, hour: 12, minute: 0) }
        )

        let summary = store.blockerSummary(containing: date(day: 20, hour: 12, minute: 0))

        #expect(summary.blockedCount == 3)
        #expect(summary.mostCommonReason == .unclearNextStep)
        #expect(summary.nextSteps == ["Ticket teilen", "Antwort von Lisa prüfen"])
    }

    @Test func focusHeatOnlyAppliesToActiveFocusProgress() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        #expect(store.focusHeatIntensity == 0)

        store.start()
        #expect(store.focusHeatIntensity == 0)

        now = date(hour: 9, minute: 10)
        store.tick()
        let earlyHeat = store.focusHeatIntensity

        now = date(hour: 9, minute: 20)
        store.tick()

        #expect(earlyHeat > 0)
        #expect(store.focusHeatIntensity > earlyHeat)

        store.pause()
        let pausedHeat = store.focusHeatIntensity
        now = date(hour: 9, minute: 22)
        store.tick()

        #expect(store.focusHeatIntensity == pausedHeat)
    }

    @Test func focusHeatClearsForPendingOutcomeAndBreak() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()

        #expect(store.pendingOutcomeSession != nil)
        #expect(store.focusHeatIntensity == 0)

        store.completePendingOutcome(.completed)
        store.startBreak()

        #expect(store.activeTimerKind == .breakTime)
        #expect(store.focusHeatIntensity == 0)
    }

    @Test func pauseBetweenSessionsIsMeasuredFromPreviousCompletion() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

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
        store.completePendingOutcome(.completed)

        now = date(hour: 9, minute: 34)
        store.start()
        now = date(hour: 9, minute: 59)
        store.tick()
        store.completePendingOutcome(.progressed)

        #expect(store.sessionsCompletedToday == 2)
        #expect(store.focusWinsToday == 2)
        #expect(store.focusMinutesToday == 50)
        #expect(store.averagePauseSecondsToday == 540)
        #expect(store.dailyGoalProgress == 0.5)
        #expect(store.dailyGoalCountText == "2/4")
        #expect(store.dailyGoalStatusText == "Noch 2 Sessions")
        #expect(store.compactTodaySummaryText == "2 · 50 min")
        #expect(store.todaySummaryText == "2 Sessions · 50 min · Ø Pause 9 min")
    }

    @Test func breakTimerCompletesWithoutRecordingSession() async {
        let defaults = makeDefaults()
        let notifier = TestPomodoroNotifier()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now }, notifier: notifier)

        store.start()
        now = date(hour: 9, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

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

    @Test func resetClearsActiveIntentWithoutRecordingSession() async {
        let defaults = makeDefaults()
        var now = date(hour: 9, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.pendingFocusIntent = "Lernen"
        store.start()

        #expect(store.activeFocusIntentText == "Lernen")
        #expect(store.pendingFocusIntent.isEmpty)

        now = date(hour: 9, minute: 10)
        store.reset()

        #expect(store.status == .idle)
        #expect(store.activeFocusIntentText == nil)
        #expect(store.sessions.isEmpty)
        #expect(store.sessionHistory.isEmpty)
    }

    @Test func dayRolloverClearsVisibleTodayLogAndKeepsHistory() async {
        let defaults = makeDefaults()
        var now = date(day: 1, hour: 23, minute: 0)
        let store = makeStore(defaults: defaults, now: { now })

        store.start()
        now = date(day: 1, hour: 23, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

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
        store.completePendingOutcome(.completed)

        now = date(day: 19, hour: 10, minute: 0)
        store.refreshForToday()
        store.start()
        now = date(day: 19, hour: 10, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

        now = date(day: 19, hour: 11, minute: 0)
        store.start()
        now = date(day: 19, hour: 11, minute: 25)
        store.tick()
        store.completePendingOutcome(.completed)

        let days = store.historyDays(containing: date(day: 19, hour: 12, minute: 0))
        let firstDay = days.first { store.isSameDay($0.date, date(day: 18, hour: 12, minute: 0)) }
        let secondDay = days.first { store.isSameDay($0.date, date(day: 19, hour: 12, minute: 0)) }

        #expect(days.count == 7)
        #expect(firstDay?.sessionCount == 1)
        #expect(firstDay?.focusWinCount == 1)
        #expect(firstDay?.focusMinutes == 25)
        #expect(secondDay?.sessionCount == 2)
        #expect(secondDay?.focusWinCount == 2)
        #expect(secondDay?.focusMinutes == 50)
    }

    @Test func historyDayAnalysisDerivesOutcomesRescueMomentumAndBlockers() async {
        let day = PomodoroHistoryDay(
            date: date(day: 18, hour: 0, minute: 0),
            sessions: [
                session(day: 18, startHour: 8, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 18, startHour: 8, startMinute: 30, outcome: .completed, isOutcomeTracked: true, isRescue: true),
                session(day: 18, startHour: 9, startMinute: 0, outcome: .progressed, isOutcomeTracked: true),
                session(day: 18, startHour: 9, startMinute: 30, outcome: .blocked, isOutcomeTracked: true, blockerReason: .unclearNextStep, blockerNextStep: "Erster Schritt"),
                session(day: 18, startHour: 10, startMinute: 0, outcome: .blocked, isOutcomeTracked: true, blockerReason: .unclearNextStep),
                session(day: 18, startHour: 10, startMinute: 30, outcome: .blocked, isOutcomeTracked: true, blockerReason: .waiting, blockerNextStep: "Neuester Schritt"),
                session(day: 18, startHour: 11, startMinute: 0),
                session(day: 18, startHour: 11, startMinute: 30, outcome: nil, isOutcomeTracked: true)
            ],
            dailyGoalSessions: 2
        )
        let pendingOnlyDay = PomodoroHistoryDay(
            date: date(day: 19, hour: 0, minute: 0),
            sessions: [
                session(day: 19, startHour: 9, startMinute: 0, outcome: nil, isOutcomeTracked: true)
            ],
            dailyGoalSessions: 2
        )
        let nonBlockedReasonDay = PomodoroHistoryDay(
            date: date(day: 20, hour: 0, minute: 0),
            sessions: [
                session(day: 20, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true, blockerReason: .waiting, blockerNextStep: "Nicht anzeigen")
            ],
            dailyGoalSessions: 2
        )

        #expect(day.focusWinCount == 3)
        #expect(day.completedOutcomeCount == 2)
        #expect(day.progressedOutcomeCount == 1)
        #expect(day.blockedOutcomeCount == 3)
        #expect(day.rescueCount == 1)
        #expect(day.hasMomentumActivity)
        #expect(day.primaryBlockerReason == .unclearNextStep)
        #expect(day.latestBlockerNextStep == "Neuester Schritt")
        #expect(pendingOnlyDay.hasMomentumActivity == false)
        #expect(pendingOnlyDay.completedOutcomeCount == 0)
        #expect(nonBlockedReasonDay.primaryBlockerReason == nil)
        #expect(nonBlockedReasonDay.latestBlockerNextStep == nil)
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
        #expect(summary.focusWinCount == 3)
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

    @Test func streakUsesFocusWinsInsteadOfRawSessions() async {
        let defaults = makeDefaults()
        let modelContainer = makeModelContainer()
        seedSessions(
            [
                session(day: 20, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 20, startHour: 10, startMinute: 0, outcome: .progressed, isOutcomeTracked: true),
                session(day: 21, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 21, startHour: 10, startMinute: 0, outcome: .blocked, isOutcomeTracked: true),
                session(day: 22, startHour: 9, startMinute: 0, outcome: .completed, isOutcomeTracked: true),
                session(day: 22, startHour: 10, startMinute: 0, outcome: .progressed, isOutcomeTracked: true)
            ],
            in: modelContainer
        )
        let store = makeStore(
            defaults: defaults,
            modelContainer: modelContainer,
            now: { date(day: 23, hour: 12, minute: 0) }
        )

        store.dailyGoalSessions = 2

        #expect(store.streakSummary.currentDays == 1)
        #expect(store.streakSummary.bestDays == 1)
        #expect(store.streakSummary.latestGoalDate == date(day: 22, hour: 0, minute: 0))
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
        store.completePendingOutcome(.completed)

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
            pausedRemainingSeconds: nil,
            pendingFocusIntent: nil,
            activeFocusIntent: nil,
            pendingOutcomeSessionID: nil
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
        store.completePendingOutcome(.completed)
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
        store.completePendingOutcome(.completed)

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
        store.completePendingOutcome(.completed)

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

    private func drainNotificationTasks() async {
        await Task.yield()
        await Task.yield()
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
        durationMinutes: Int = PomodoroStore.defaultMinutes,
        intent: String? = nil,
        outcome: PomodoroSessionOutcome? = nil,
        isOutcomeTracked: Bool = false,
        isRescue: Bool = false,
        blockerReason: PomodoroBlockerReason? = nil,
        blockerNextStep: String? = nil
    ) -> PomodoroSession {
        let startedAt = date(day: day, hour: startHour, minute: startMinute)
        let endedAt = testCalendar.date(byAdding: .minute, value: durationMinutes, to: startedAt) ?? startedAt

        return PomodoroSession(
            startedAt: startedAt,
            endedAt: endedAt,
            plannedMinutes: durationMinutes,
            pauseBeforeSeconds: nil,
            intent: intent,
            outcome: outcome,
            isOutcomeTracked: isOutcomeTracked,
            isRescue: isRescue,
            blockerReason: blockerReason,
            blockerNextStep: blockerNextStep
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
