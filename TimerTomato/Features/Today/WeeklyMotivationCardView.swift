//
//  WeeklyMotivationCardView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct WeeklyMotivationCardView: View {
    let store: PomodoroStore

    private var weekSummary: PomodoroWeekSummary {
        store.currentWeekSummary
    }

    private var streakSummary: PomodoroStreakSummary {
        store.streakSummary
    }

    private var bestFocusDay: PomodoroBestFocusDay? {
        store.bestFocusDays(limit: 1).first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Label("Woche", systemImage: "chart.bar.fill")
                    .font(.footnote)
                    .bold()

                Spacer(minLength: 10)

                Text(weekSummary.goalCountText)
                    .font(.footnote.monospacedDigit())
                    .bold()
                    .foregroundStyle(weekSummary.didReachGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
            }

            TimerProgressBarView(progress: weekSummary.goalProgress, tint: TimerTomatoDesign.mint)
                .frame(height: 6)

            HStack(spacing: 4) {
                ForEach(weekSummary.days) { day in
                    WeeklyDayProgressView(
                        day: day,
                        isCurrent: store.isSameDay(day.date, store.currentDate)
                    )
                }
            }

            HStack(spacing: 8) {
                Label(streakSummary.currentText, systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(streakSummary.currentDays > 0 ? TimerTomatoDesign.tomato : TimerTomatoDesign.tertiaryText)

                Spacer(minLength: 8)

                bestFocusDayLabel
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .timerTomatoCard(.row)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Woche \(weekSummary.goalCountText), Streak \(streakSummary.currentText)")
    }

    @ViewBuilder
    private var bestFocusDayLabel: some View {
        if let bestFocusDay {
            Label(
                "\(bestFocusDay.focusMinutes) min",
                systemImage: "star.fill"
            )
            .font(.caption)
            .foregroundStyle(TimerTomatoDesign.secondaryText)
            .help(bestFocusDay.date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
        } else {
            Label("0 min", systemImage: "star")
                .font(.caption)
                .foregroundStyle(TimerTomatoDesign.tertiaryText)
        }
    }
}

#if DEBUG
#Preview("Wochenmotivation") {
    WeeklyMotivationCardView(
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
