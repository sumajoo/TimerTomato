//
//  HistoryDayCellView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryDayCellView: View {
    let day: PomodoroHistoryDay
    let isSelected: Bool
    let glassNamespace: Namespace.ID
    let select: () -> Void

    private var weekdayText: String {
        day.date.formatted(.dateTime.weekday(.narrow))
    }

    private var dayText: String {
        day.date.formatted(.dateTime.day())
    }

    private var progressColor: Color {
        day.didReachGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    var body: some View {
        Button(action: select) {
            content
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide))), \(day.sessionCount) Sitzungen")
        .accessibilityHint("Der Balken zeigt den Fortschritt zum Tagesziel.")
        .help("Tagesziel-Fortschritt")
    }

    @ViewBuilder
    private var content: some View {
        if isSelected {
            baseContent
                .background {
                    RoundedRectangle(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(
                    .regular.interactive(),
                    in: .rect(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                )
                .glassEffectID("history-day-selection", in: glassNamespace)
                .timerTomatoCardBorder(cornerRadius: TimerTomatoDesign.rowCornerRadius)
        } else {
            baseContent
        }
    }

    private var baseContent: some View {
        VStack(spacing: 5) {
            Text(weekdayText)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(dayText)
                .font(.callout.monospacedDigit())
                .bold()

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.tertiary)

                if day.sessionCount > 0 {
                    GeometryReader { proxy in
                        Capsule()
                            .fill(progressColor)
                            .frame(width: proxy.size.width * CGFloat(day.goalProgress))
                    }
                }
            }
            .frame(height: 3)

            Text(day.sessionCount == 0 ? "-" : "\(day.sessionCount)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(day.sessionCount == 0 ? .tertiary : .secondary)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 58)
    }
}

#if DEBUG
#Preview("Kalendertag") {
    @Previewable @Namespace var glassNamespace

    HistoryDayCellView(
        day: TimerTomatoPreviewData.sampleHistoryDay,
        isSelected: true,
        glassNamespace: glassNamespace,
        select: {}
    )
    .padding()
    .frame(width: 96)
}
#endif
