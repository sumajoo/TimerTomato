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

    private var summaryText: String {
        "Heute \(store.dailyGoalCountText) · \(store.focusMinutesToday) min"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(summaryText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 10)

                Image(systemName: goalProgress >= 1 ? "checkmark.circle.fill" : "target")
                    .font(.caption)
                    .foregroundStyle(goalProgress >= 1 ? TimerTomatoDesign.mint : TimerTomatoDesign.tertiaryText)
                    .accessibilityHidden(true)
            }

            TimerProgressBarView(progress: goalProgress, tint: TimerTomatoDesign.mint)
                .frame(height: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .timerTomatoCard(.row)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Heute \(store.dailyGoalCountText), \(store.focusMinutesToday) Minuten")
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
