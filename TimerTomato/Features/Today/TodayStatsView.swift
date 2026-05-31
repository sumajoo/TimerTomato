//
//  TodayStatsView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TodayStatsView: View {
    @Bindable var store: PomodoroStore

    private var goalProgress: Double {
        store.dailyGoalProgress
    }

    private var topicSummaries: [PomodoroTopicSummary] {
        store.topicSummaries(on: store.currentDate)
    }

    private var topicSummaryText: String? {
        compactTopicText(limit: 2)
    }

    private var fullTopicSummaryText: String {
        topicSummaries
            .map { summary in "\(PomodoroFormatters.topicTitle(summary.intent)) \(PomodoroFormatters.topicMinutesText(seconds: summary.focusSeconds))" }
            .joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline) {
                Text(store.todaySummaryText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 10)

                Text(store.dailyGoalCountText)
                    .font(.footnote.monospacedDigit())
                    .bold()
                    .foregroundStyle(goalProgress >= 1 ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
            }

            TimerProgressBarView(progress: goalProgress, tint: TimerTomatoDesign.mint)
                .frame(height: 6)

            if let topicSummaryText {
                Label(topicSummaryText, systemImage: "tag.fill")
                    .font(.caption2)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.82)
                    .help(fullTopicSummaryText)
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Tagesziel")
                        .font(.footnote)
                        .bold()

                    Text(store.dailyGoalStatusText)
                        .font(.footnote)
                        .foregroundStyle(TimerTomatoDesign.tertiaryText)
                }

                Spacer()

                HStack(spacing: 0) {
                    StepperIconButton(
                        title: "Tagesziel senken",
                        systemImage: "minus",
                        isDisabled: store.dailyGoalSessions <= PomodoroStore.minimumDailyGoalSessions,
                        action: store.decreaseDailyGoalSessions
                    )

                    Text("\(store.dailyGoalSessions)")
                        .font(.footnote.monospacedDigit())
                        .bold()
                        .frame(minWidth: 20)

                    StepperIconButton(
                        title: "Tagesziel erhöhen",
                        systemImage: "plus",
                        isDisabled: store.dailyGoalSessions >= PomodoroStore.maximumDailyGoalSessions,
                        action: store.increaseDailyGoalSessions
                    )
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(
                    .regular.interactive(),
                    in: .capsule
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .timerTomatoCard(.row)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Heute \(store.todaySummaryText), Tagesziel \(store.dailyGoalCountText)")
    }

    private func compactTopicText(limit: Int) -> String? {
        guard !topicSummaries.isEmpty else {
            return nil
        }

        let visibleSummaries = Array(topicSummaries.prefix(limit))
        let visibleText = visibleSummaries
            .map { summary in "\(PomodoroFormatters.topicTitle(summary.intent)) \(PomodoroFormatters.topicMinutesText(seconds: summary.focusSeconds))" }
            .joined(separator: " · ")
        let remainingCount = topicSummaries.count - visibleSummaries.count

        if remainingCount > 0 {
            return "Themen: \(visibleText) · +\(remainingCount)"
        }

        return "Themen: \(visibleText)"
    }
}

#if DEBUG
#Preview("Heute Statistik") {
    TodayStatsView(
        store: TimerTomatoPreviewData.store()
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
