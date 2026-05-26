//
//  HistoryWeekSummaryView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryWeekSummaryView: View {
    @Bindable var store: PomodoroStore

    let selectedDate: Date

    private var weekSummary: PomodoroWeekSummary {
        store.weekSummary(containing: selectedDate)
    }

    private var streakSummary: PomodoroStreakSummary {
        store.streakSummary
    }

    private var momentumSummary: PomodoroMomentumSummary {
        store.momentumSummary(endingAt: selectedDate)
    }

    private var blockerSummary: PomodoroBlockerSummary {
        store.blockerSummary(containing: selectedDate)
    }

    private var bestFocusDays: [PomodoroBestFocusDay] {
        store.bestFocusDays(limit: 3)
    }

    private var shouldShowSuggestion: Bool {
        store.weeklyGoalSuggestionSessions != store.weeklyGoalSessions
    }

    private var shouldShowRescueAction: Bool {
        store.shouldShowRescueAction(containing: selectedDate)
    }

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(alignment: .leading, spacing: 14) {
                header

                TimerProgressBarView(progress: weekSummary.goalProgress, tint: TimerTomatoDesign.mint)
                    .frame(height: 7)

                progressContext

                if shouldShowRescueAction {
                    rescueAction
                }

                if blockerSummary.hasBlockers {
                    blockerHint
                }

                if let bestFocusDayText {
                    Label(bestFocusDayText, systemImage: "trophy.fill")
                        .font(.footnote)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                if shouldShowSuggestion {
                    Button(
                        "Quest-Vorschlag \(store.weeklyGoalSuggestionSessions) übernehmen",
                        action: store.acceptWeeklyGoalSuggestion
                    )
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .timerTomatoHitTarget(minWidth: 180)
                    .background {
                        Capsule()
                            .fill(TimerTomatoDesign.surfaceFill)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .help("Wochen-Quest-Vorschlag übernehmen")
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .timerTomatoCard(.panel)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Wochen-Quest")
                    .font(.callout)
                    .bold()

                Text("Diese Woche: \(weekSummary.goalCountText) Sessions")
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(store.weeklyQuestStatusText(containing: selectedDate))
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 10)

            HStack(spacing: 0) {
                StepperIconButton(
                    title: "Wochen-Quest senken",
                    systemImage: "minus",
                    isDisabled: store.weeklyGoalSessions <= PomodoroStore.minimumWeeklyGoalSessions,
                    action: store.decreaseWeeklyGoalSessions
                )

                Text("\(store.weeklyGoalSessions)")
                    .font(.footnote.monospacedDigit())
                    .bold()
                    .frame(minWidth: 22)

                StepperIconButton(
                    title: "Wochen-Quest erhöhen",
                    systemImage: "plus",
                    isDisabled: store.weeklyGoalSessions >= PomodoroStore.maximumWeeklyGoalSessions,
                    action: store.increaseWeeklyGoalSessions
                )
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
            }
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }

    private var progressContext: some View {
        VStack(alignment: .leading, spacing: 6) {
            contextLine("Ziel-Serie: \(streakSummary.currentText)", systemImage: "flame.fill", tint: TimerTomatoDesign.mint)
            contextLine("Letzte 7 Tage: \(activeDaysText)", systemImage: "checkmark.circle.fill", tint: TimerTomatoDesign.secondaryText)

            if store.isSameDay(selectedDate, store.currentDate), momentumSummary.hasActivityToday {
                contextLine("Heute bist du drangeblieben", systemImage: "sparkles", tint: TimerTomatoDesign.mint)
            }
        }
    }

    private var rescueAction: some View {
        Button(action: store.startRescueFocus) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.circle.fill")
                    .foregroundStyle(TimerTomatoDesign.mint)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Kurz dranbleiben")
                        .font(.caption.bold())

                    Text("10-min Reset reicht heute")
                        .font(.caption2)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.82)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 34)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .timerTomatoHitTarget()
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    Capsule()
                        .fill(TimerTomatoDesign.mint.opacity(0.08))
                }
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .help("10 Minuten Reset starten")
    }

    private var blockerHint: some View {
        Label(blockerHintText, systemImage: "exclamationmark.circle.fill")
            .font(.footnote)
            .foregroundStyle(TimerTomatoDesign.secondaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
    }

    private var blockerHintText: String {
        if let mostCommonReason = blockerSummary.mostCommonReason {
            return "Diese Woche \(blockerSummary.blockedCount)x blockiert · häufig: \(mostCommonReason.title)"
        }

        return "Diese Woche \(blockerSummary.blockedCount)x blockiert"
    }

    private var bestFocusDayText: String? {
        guard let bestFocusDay = bestFocusDays.first else {
            return nil
        }

        let title = store.isSameDay(bestFocusDay.date, store.currentDate)
            ? "Heute"
            : bestFocusDay.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return "Bester Tag: \(title) · \(bestFocusDay.focusMinutes) min"
    }

    private var activeDaysText: String {
        let activeDayCount = momentumSummary.activeDayCount
        let dayText = activeDayCount == 1 ? "aktiver Tag" : "aktive Tage"
        return "\(activeDayCount)/\(momentumSummary.days.count) \(dayText)"
    }

    private func contextLine(_ title: String, systemImage: String, tint: Color) -> some View {
        Label {
            Text(title)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
        }
        .font(.footnote)
        .lineLimit(1)
        .minimumScaleFactor(0.82)
    }
}

#if DEBUG
#Preview("Wochenziel Verlauf") {
    HistoryWeekSummaryView(
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions),
        selectedDate: TimerTomatoPreviewData.referenceDate
    )
    .padding()
    .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
