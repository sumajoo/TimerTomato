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

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(alignment: .leading, spacing: 14) {
                header

                TimerProgressBarView(progress: weekSummary.goalProgress, tint: TimerTomatoDesign.mint)
                    .frame(height: 7)

                progressContext

                if blockerSummary.hasBlockers {
                    blockerHint
                }

                if !bestFocusDays.isEmpty {
                    bestFocusDaysView
                }

                if shouldShowSuggestion {
                    Button(action: store.acceptWeeklyGoalSuggestion) {
                        Text("Quest-Vorschlag \(store.weeklyGoalSuggestionSessions) übernehmen")
                            .font(.caption)
                            .foregroundStyle(TimerTomatoDesign.mint)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .timerTomatoCapsuleHitTarget(minWidth: 180)
                    }
                    .background {
                        Capsule()
                            .fill(TimerTomatoDesign.surfaceFill)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .buttonStyle(.plain)
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
        }
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

    private var bestFocusDaysView: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("Beste Fokus-Tage", systemImage: "trophy.fill")
                .font(.footnote.bold())
                .foregroundStyle(.primary)
                .labelStyle(.titleAndIcon)

            HStack(spacing: 7) {
                ForEach(Array(bestFocusDays.enumerated()), id: \.element.id) { index, day in
                    BestFocusDayChip(
                        rank: index + 1,
                        title: bestFocusDayTitle(for: day.date),
                        day: day
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func bestFocusDayTitle(for date: Date) -> String {
        if store.isSameDay(date, store.currentDate) {
            return "Heute"
        }

        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
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

private struct BestFocusDayChip: View {
    let rank: Int
    let title: String
    let day: PomodoroBestFocusDay

    private var sessionText: String {
        day.sessionCount == 1 ? "1 Session" : "\(day.sessionCount) Sessions"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("#\(rank)")
                .font(.caption2.monospacedDigit())
                .fontWeight(.semibold)
                .foregroundStyle(TimerTomatoDesign.mint)

            Text(title)
                .font(.caption2)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text("\(day.focusMinutes) min")
                .font(.caption.monospacedDigit())
                .fontWeight(.semibold)

            Text(sessionText)
                .font(.caption2)
                .foregroundStyle(TimerTomatoDesign.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .frame(width: 106, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TimerTomatoDesign.mint.opacity(0.10))
        }
        .accessibilityLabel("Platz \(rank), \(title), \(day.focusMinutes) Minuten, \(sessionText)")
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
