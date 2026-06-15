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
    let isDimmed: Bool
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

    private var secondaryTextColor: Color {
        isDimmed ? TimerTomatoDesign.tertiaryText : TimerTomatoDesign.secondaryText
    }

    private var countTextColor: Color {
        if day.focusWinCount == 0 || isDimmed {
            return TimerTomatoDesign.tertiaryText
        }

        return TimerTomatoDesign.secondaryText
    }

    private var accessibilityMonthContext: String {
        isDimmed ? ", außerhalb des Monats" : ""
    }

    var body: some View {
        Button(action: select) {
            baseContent
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityLabel(
            "\(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide))), \(day.focusWinCount) Sessions\(accessibilityMonthContext)"
        )
        .accessibilityHint("Der Balken zeigt den Fortschritt zum Tagesziel.")
        .help("Tagesziel-Fortschritt")
    }

    @ViewBuilder
    private var dayNumber: some View {
        if isSelected {
            Text(dayText)
                .font(.callout.monospacedDigit())
                .bold()
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                        .overlay {
                            Capsule()
                                .fill(TimerTomatoDesign.mint.opacity(0.12))
                        }
                }
                .glassEffect(
                    .regular.interactive(),
                    in: .capsule
                )
                .overlay {
                    Capsule()
                        .stroke(TimerTomatoDesign.mint.opacity(0.28), lineWidth: TimerTomatoDesign.cardBorderWidth)
                        .allowsHitTesting(false)
                }
                .glassEffectID("history-day-selection", in: glassNamespace)
        } else {
            Text(dayText)
                .font(.callout.monospacedDigit())
                .bold()
                .padding(.vertical, 3)
        }
    }

    private var baseContent: some View {
        VStack(spacing: 4) {
            Text(weekdayText)
                .font(.footnote)
                .foregroundStyle(isSelected ? TimerTomatoDesign.mint : secondaryTextColor)

            dayNumber

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TimerTomatoDesign.trackFill.opacity(isDimmed ? 0.55 : 1))

                if day.focusWinCount > 0 {
                    GeometryReader { proxy in
                        Capsule()
                            .fill(progressColor.opacity(isDimmed ? 0.42 : 1))
                            .frame(width: proxy.size.width * CGFloat(day.goalProgress))
                    }
                }
            }
            .frame(height: 3)
            .frame(width: 42)

            Text(day.focusWinCount == 0 ? "-" : "\(day.focusWinCount)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(countTextColor)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 62)
    }
}

#if DEBUG
#Preview("Kalendertag") {
    @Previewable @Namespace var glassNamespace

    HistoryDayCellView(
        day: TimerTomatoPreviewData.sampleHistoryDay,
        isSelected: true,
        isDimmed: false,
        glassNamespace: glassNamespace,
        select: {}
    )
    .padding()
    .frame(width: 96)
}
#endif
