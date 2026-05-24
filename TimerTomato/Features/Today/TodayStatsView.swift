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

                HStack(spacing: 2) {
                    Button("Tagesziel senken", systemImage: "minus", action: store.decreaseDailyGoalSessions)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .frame(width: 26, height: 26)
                        .contentShape(Circle())
                        .disabled(store.dailyGoalSessions <= PomodoroStore.minimumDailyGoalSessions)
                        .help("Tagesziel senken")

                    Text("\(store.dailyGoalSessions)")
                        .font(.footnote.monospacedDigit())
                        .bold()
                        .frame(minWidth: 18)

                    Button("Tagesziel erhöhen", systemImage: "plus", action: store.increaseDailyGoalSessions)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .frame(width: 26, height: 26)
                        .contentShape(Circle())
                        .disabled(store.dailyGoalSessions >= PomodoroStore.maximumDailyGoalSessions)
                        .help("Tagesziel erhöhen")
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
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
