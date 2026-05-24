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
            VStack(spacing: 6) {
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
                .frame(height: 4)

                Text(day.sessionCount == 0 ? "-" : "\(day.sessionCount)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(day.sessionCount == 0 ? .tertiary : .secondary)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background {
                RoundedRectangle(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                    .fill(isSelected ? TimerTomatoDesign.surfaceFill : .clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                    .strokeBorder(isSelected ? TimerTomatoDesign.surfaceMidline : .clear, lineWidth: 0.7)
            }
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: TimerTomatoDesign.rowCornerRadius)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide))), \(day.sessionCount) Sitzungen")
    }
}
