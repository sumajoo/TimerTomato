//
//  HistoryDayDetailView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryDayDetailView: View {
    let store: PomodoroStore
    let selectedDate: Date

    private var day: PomodoroHistoryDay {
        PomodoroHistoryDay(
            date: selectedDate,
            sessions: store.sessions(on: selectedDate),
            dailyGoalSessions: store.dailyGoalSessions
        )
    }

    private var summaryText: String {
        PomodoroFormatters.focusWinsSummaryText(
            focusWins: day.focusWinCount,
            focusMinutes: day.focusMinutes,
            averagePauseSeconds: nil
        )
    }

    private var focusRoundUnitText: String {
        day.focusWinCount == 1 ? "Session" : "Sessions"
    }

    private var minuteUnitText: String {
        day.focusMinutes == 1 ? "Minute Fokus" : "Minuten Fokus"
    }

    private var goalText: String {
        if day.didReachGoal {
            return "Tagesziel erreicht"
        }

        let remainingWins = store.dailyGoalSessions - day.focusWinCount
        let unit = remainingWins == 1 ? "Session" : "Sessions"
        return "Noch \(remainingWins) \(unit) bis zum Ziel"
    }

    private var blockerInsightText: String? {
        guard let primaryBlockerReason = day.primaryBlockerReason else {
            return nil
        }

        if let latestBlockerNextStep = day.latestBlockerNextStep {
            return "Blockiert: \(primaryBlockerReason.title) · Nächster Schritt: \(latestBlockerNextStep)"
        }

        return "Blockiert: \(primaryBlockerReason.title)"
    }

    private var hasOutcomeInsights: Bool {
        day.completedOutcomeCount > 0 || day.progressedOutcomeCount > 0 || day.blockedOutcomeCount > 0
    }

    private var hasStatusInsights: Bool {
        day.rescueCount > 0 || day.hasMomentumActivity
    }

    private var topicSummaries: [PomodoroTopicSummary] {
        day.topicSummaries
    }

    private var totalTopicSeconds: TimeInterval {
        topicSummaries.reduce(0) { result, summary in
            result + summary.focusSeconds
        }
    }

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.dayTitle(for: selectedDate))
                            .font(.callout)
                            .bold()

                        Text(day.sessions.isEmpty ? "Keine Sessions" : summaryText)
                            .font(.footnote)
                            .foregroundStyle(TimerTomatoDesign.secondaryText)
                    }

                    Spacer()

                    Text(day.goalCountText)
                        .font(.footnote.monospacedDigit())
                        .bold()
                        .foregroundStyle(day.didReachGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                }

                if day.sessions.isEmpty {
                    HistoryEmptyStateView()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        metricRow
                        topicSummarySection
                        insightChips
                        blockerInsight
                        goalStatus
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .timerTomatoCard(.panel)
        }
    }

    private var metricRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(day.focusWinCount)")
                    .font(.system(.largeTitle, design: .rounded))
                    .monospacedDigit()
                    .bold()

                Text(focusRoundUnitText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
            }

            Divider()
                .frame(height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(day.focusMinutes)")
                    .font(.system(.largeTitle, design: .rounded))
                    .monospacedDigit()
                    .bold()

                Text(minuteUnitText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
            }
        }
    }

    @ViewBuilder
    private var topicSummarySection: some View {
        if !topicSummaries.isEmpty {
            VStack(alignment: .leading, spacing: 7) {
                Label("Themen", systemImage: "tag.fill")
                    .font(.footnote.bold())
                    .foregroundStyle(.primary)
                    .labelStyle(.titleAndIcon)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(topicSummaries.prefix(3))) { summary in
                        TopicSummaryRow(
                            summary: summary,
                            totalSeconds: totalTopicSeconds
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var insightChips: some View {
        if hasOutcomeInsights || hasStatusInsights {
            VStack(alignment: .leading, spacing: 7) {
                if hasOutcomeInsights {
                    HStack(spacing: 7) {
                        if day.completedOutcomeCount > 0 {
                            insightChip("Erledigt \(day.completedOutcomeCount)", systemImage: PomodoroSessionOutcome.completed.systemImage, tint: TimerTomatoDesign.mint)
                        }

                        if day.progressedOutcomeCount > 0 {
                            insightChip("\(PomodoroSessionOutcome.progressed.shortTitle) \(day.progressedOutcomeCount)", systemImage: PomodoroSessionOutcome.progressed.systemImage, tint: TimerTomatoDesign.mint)
                        }

                        if day.blockedOutcomeCount > 0 {
                            insightChip("Blockiert \(day.blockedOutcomeCount)", systemImage: PomodoroSessionOutcome.blocked.systemImage, tint: TimerTomatoDesign.tomato)
                        }

                        Spacer(minLength: 0)
                    }
                }

                if hasStatusInsights {
                    HStack(spacing: 7) {
                        if day.rescueCount > 0 {
                            insightChip("Reset \(day.rescueCount)", systemImage: "bolt.circle.fill", tint: TimerTomatoDesign.mint)
                        }

                        if day.hasMomentumActivity {
                            insightChip("Drangeblieben", systemImage: "sparkles", tint: TimerTomatoDesign.mint)
                        }

                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var blockerInsight: some View {
        if let blockerInsightText {
            Label(blockerInsightText, systemImage: "exclamationmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.82)
        }
    }

    private var goalStatus: some View {
        Label(
            goalText,
            systemImage: day.didReachGoal ? "checkmark.circle.fill" : "target"
        )
        .font(.footnote)
        .foregroundStyle(day.didReachGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
    }

    private func insightChip(_ title: String, systemImage: String, tint: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.bold())
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.trackFill)
                    .overlay {
                        Capsule()
                            .fill(tint.opacity(0.08))
                    }
            }
    }
}

private struct TopicSummaryRow: View {
    let summary: PomodoroTopicSummary
    let totalSeconds: TimeInterval

    private var progress: Double {
        guard totalSeconds > 0 else {
            return 0
        }

        return min(max(summary.focusSeconds / totalSeconds, 0), 1)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(PomodoroFormatters.topicTitle(summary.intent))
                .font(.caption)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(PomodoroFormatters.topicTitle(summary.intent))

            Spacer(minLength: 8)

            TimerProgressBarView(progress: progress, tint: TimerTomatoDesign.mint)
                .frame(width: 74, height: 4)

            Text(PomodoroFormatters.topicMinutesText(seconds: summary.focusSeconds))
                .font(.caption.monospacedDigit())
                .fontWeight(.semibold)
                .frame(width: 44, alignment: .trailing)
        }
    }
}

#if DEBUG
#Preview("Tagesdetails") {
    HistoryDayDetailView(
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions),
        selectedDate: TimerTomatoPreviewData.referenceDate
    )
    .padding()
    .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
