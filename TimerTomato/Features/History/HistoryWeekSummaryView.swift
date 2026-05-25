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

                HStack(spacing: 10) {
                    metricBadge(
                        title: "Momentum",
                        value: momentumSummary.countText,
                        systemImage: "sparkles"
                    )

                    metricBadge(
                        title: "Aktuell",
                        value: streakSummary.currentText,
                        systemImage: "flame.fill"
                    )

                    metricBadge(
                        title: "Beste Serie",
                        value: streakSummary.bestText,
                        systemImage: "bolt.fill"
                    )
                }

                momentumStrip

                if shouldShowRescueAction {
                    Button(action: store.startRescueFocus) {
                        Label("Heute reicht eine kurze Einheit fürs Momentum", systemImage: "bolt.circle.fill")
                            .font(.caption.bold())
                            .labelStyle(.titleAndIcon)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .foregroundStyle(TimerTomatoDesign.mint)
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.plain)
                    .background {
                        Capsule()
                            .fill(TimerTomatoDesign.surfaceFill)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .help("10 Minuten Rescue-Fokus starten")
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

            HStack(spacing: 2) {
                Button("Wochen-Quest senken", systemImage: "minus", action: store.decreaseWeeklyGoalSessions)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .frame(width: 26, height: 26)
                    .contentShape(Circle())
                    .disabled(store.weeklyGoalSessions <= PomodoroStore.minimumWeeklyGoalSessions)
                    .help("Wochen-Quest senken")

                Text("\(store.weeklyGoalSessions)")
                    .font(.footnote.monospacedDigit())
                    .bold()
                    .frame(minWidth: 22)

                Button("Wochen-Quest erhöhen", systemImage: "plus", action: store.increaseWeeklyGoalSessions)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .frame(width: 26, height: 26)
                    .contentShape(Circle())
                    .disabled(store.weeklyGoalSessions >= PomodoroStore.maximumWeeklyGoalSessions)
                    .help("Wochen-Quest erhöhen")
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

    private var momentumStrip: some View {
        HStack(spacing: 5) {
            ForEach(momentumSummary.days) { day in
                Capsule()
                    .fill(day.hasActivity ? TimerTomatoDesign.mint : TimerTomatoDesign.trackFill)
                    .frame(height: 7)
                    .overlay {
                        if store.isSameDay(day.date, store.currentDate) {
                            Capsule()
                                .stroke(TimerTomatoDesign.mint.opacity(0.55), lineWidth: 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("\(day.date.formatted(.dateTime.weekday(.wide))), \(day.hasActivity ? "Momentum erreicht" : "kein Momentum")")
            }
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

    private var bestFocusDayText: String? {
        guard let bestFocusDay = bestFocusDays.first else {
            return nil
        }

        let title = store.isSameDay(bestFocusDay.date, store.currentDate)
            ? "Heute"
            : bestFocusDay.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return "Bester Tag: \(title) · \(bestFocusDay.focusMinutes) min"
    }

    private func metricBadge(title: String, value: String, systemImage: String) -> some View {
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
