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
                .foregroundStyle(TimerTomatoDesign.mint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(session.plannedMinutes) Minuten Fokus")
                    .font(.subheadline)
                    .bold()

                Text(timeRangeText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
            }

            Spacer()

            Text(PomodoroFormatters.pauseText(seconds: session.pauseBeforeSeconds))
                .font(.footnote)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .timerTomatoCard(.row)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Sitzungszeile") {
    SessionRowView(
        session: TimerTomatoPreviewData.sampleSession
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
