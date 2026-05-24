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

                HStack(spacing: 5) {
                    ForEach(weekSummary.days) { day in
                        WeeklyDayProgressView(
                            day: day,
                            isCurrent: store.isSameDay(day.date, store.currentDate)
                        )
                    }
                }

                HStack(spacing: 10) {
                    streakBadge(
                        title: "Aktuell",
                        value: streakSummary.currentText,
                        systemImage: "flame.fill"
                    )

                    streakBadge(
                        title: "Beste Serie",
                        value: streakSummary.bestText,
                        systemImage: "bolt.fill"
                    )
                }

                bestFocusDaysView

                if shouldShowSuggestion {
                    Button(
                        "Vorschlag \(store.weeklyGoalSuggestionSessions) übernehmen",
                        action: store.acceptWeeklyGoalSuggestion
                    )
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(TimerTomatoDesign.surfaceFill)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .help("Wochenziel-Vorschlag übernehmen")
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
                Text("Wochenziel")
                    .font(.callout)
                    .bold()

                Text("\(weekSummary.sessionCount) Sitzungen · \(weekSummary.focusMinutes) min")
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
            }

            Spacer(minLength: 10)

            HStack(spacing: 2) {
                Button("Wochenziel senken", systemImage: "minus", action: store.decreaseWeeklyGoalSessions)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .frame(width: 26, height: 26)
                    .contentShape(Circle())
                    .disabled(store.weeklyGoalSessions <= PomodoroStore.minimumWeeklyGoalSessions)
                    .help("Wochenziel senken")

                Text("\(store.weeklyGoalSessions)")
                    .font(.footnote.monospacedDigit())
                    .bold()
                    .frame(minWidth: 22)

                Button("Wochenziel erhöhen", systemImage: "plus", action: store.increaseWeeklyGoalSessions)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .frame(width: 26, height: 26)
                    .contentShape(Circle())
                    .disabled(store.weeklyGoalSessions >= PomodoroStore.maximumWeeklyGoalSessions)
                    .help("Wochenziel erhöhen")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
            }
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }

    private var bestFocusDaysView: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Beste Fokus-Tage")
                .font(.footnote)
                .bold()

            if bestFocusDays.isEmpty {
                Text("Noch keine Fokus-Tage")
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.tertiaryText)
            } else {
                HStack(spacing: 7) {
                    ForEach(Array(bestFocusDays.enumerated()), id: \.element.id) { index, day in
                        BestFocusDayChip(rank: index + 1, day: day)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func streakBadge(title: String, value: String, systemImage: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.footnote)
                    .bold()

                Text(title)
                    .font(.caption2)
                    .foregroundStyle(TimerTomatoDesign.tertiaryText)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(TimerTomatoDesign.mint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BestFocusDayChip: View {
    let rank: Int
    let day: PomodoroBestFocusDay

    private var dateText: String {
        day.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("#\(rank)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(TimerTomatoDesign.mint)

            Text(dateText)
                .font(.caption2)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .lineLimit(1)

            Text("\(day.focusMinutes) min")
                .font(.caption.monospacedDigit())
                .bold()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(width: 104, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(TimerTomatoDesign.trackFill)
        }
        .accessibilityLabel("Platz \(rank), \(dateText), \(day.focusMinutes) Minuten Fokus")
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
