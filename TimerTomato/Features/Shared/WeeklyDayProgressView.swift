//
//  WeeklyDayProgressView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct WeeklyDayProgressView: View {
    let day: PomodoroHistoryDay
    let isCurrent: Bool

    private var weekdayText: String {
        day.date.formatted(.dateTime.weekday(.narrow))
    }

    private var countText: String {
        day.focusWinCount == 0 ? "-" : "\(day.focusWinCount)"
    }

    private var tint: Color {
        day.didReachGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekdayText)
                .font(.caption2)
                .foregroundStyle(isCurrent ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)

            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(TimerTomatoDesign.trackFill)

                    if day.focusWinCount > 0 {
                        Capsule()
                            .fill(tint)
                            .frame(height: max(3, proxy.size.height * CGFloat(day.goalProgress)))
                    }
                }
            }
            .frame(width: 7, height: 30)
            .overlay {
                if isCurrent {
                    Capsule()
                        .stroke(TimerTomatoDesign.mint.opacity(0.55), lineWidth: 1)
                }
            }

            Text(countText)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(day.focusWinCount == 0 ? TimerTomatoDesign.tertiaryText : TimerTomatoDesign.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(weekdayText), \(day.focusWinCount) Sessions")
    }
}
