//
//  SessionRowView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct SessionRowView: View {
    let session: PomodoroSession

    private var timeRangeText: String {
        let start = session.startedAt.formatted(date: .omitted, time: .shortened)
        let end = session.endedAt.formatted(date: .omitted, time: .shortened)
        return "\(start) - \(end)"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(session.plannedMinutes) Minuten Fokus")
                    .font(.subheadline)
                    .bold()

                Text(timeRangeText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(PomodoroFormatters.pauseText(seconds: session.pauseBeforeSeconds))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            TimerTomatoDesign.surfaceHighlight,
                            TimerTomatoDesign.surfaceMidline,
                            TimerTomatoDesign.surfaceLowlight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.65
                )
        }
        .shadow(color: TimerTomatoDesign.panelShadow, radius: 14, x: 0, y: 8)
        .accessibilityElement(children: .combine)
    }
}
