//
//  HistorySessionRowView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistorySessionRowView: View {
    let session: PomodoroSession

    private var timeText: String {
        let start = session.startedAt.formatted(date: .omitted, time: .shortened)
        let end = session.endedAt.formatted(date: .omitted, time: .shortened)
        return "\(start) - \(end)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(TimerTomatoDesign.mint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(session.plannedMinutes) Minuten Fokus")
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(timeText)
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(PomodoroFormatters.pauseText(seconds: session.pauseBeforeSeconds))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .layoutPriority(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: TimerTomatoDesign.rowCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                .strokeBorder(TimerTomatoDesign.surfaceMidline, lineWidth: 0.65)
        }
        .accessibilityElement(children: .combine)
    }
}
