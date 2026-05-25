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

    private var subtitleText: String {
        if session.isRescue {
            return "\(session.plannedMinutes)-min Rescue · \(timeRangeText)"
        }

        if session.intentTitle != nil {
            return "\(session.plannedMinutes) min Fokus · \(timeRangeText)"
        }

        return timeRangeText
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: leadingSystemImage)
                .font(.title3)
                .foregroundStyle(leadingTint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(session.displayTitle)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)

                Text(subtitleText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                outcomeBadge

                Text(PomodoroFormatters.pauseText(seconds: session.pauseBeforeSeconds))
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .timerTomatoCard(.row)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var outcomeBadge: some View {
        if session.isOutcomeTracked {
            Label(outcomeText, systemImage: outcomeSystemImage)
                .font(.caption2)
                .labelStyle(.titleAndIcon)
                .foregroundStyle(outcomeTint)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .fill(outcomeTint.opacity(0.10))
                }
        }
    }

    private var leadingSystemImage: String {
        if session.isPendingOutcome {
            return "questionmark.circle.fill"
        }

        if session.isRescue {
            return "bolt.circle.fill"
        }

        return session.isFocusWin ? "checkmark.circle.fill" : "minus.circle.fill"
    }

    private var leadingTint: Color {
        if session.isPendingOutcome {
            return TimerTomatoDesign.tertiaryText
        }

        if session.isRescue {
            return TimerTomatoDesign.mint
        }

        return session.isFocusWin ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    private var outcomeText: String {
        session.outcome?.shortTitle ?? "Offen"
    }

    private var outcomeSystemImage: String {
        session.outcome?.systemImage ?? "questionmark.circle.fill"
    }

    private var outcomeTint: Color {
        guard let outcome = session.outcome else {
            return TimerTomatoDesign.tertiaryText
        }

        return outcome == .blocked ? TimerTomatoDesign.tomato : TimerTomatoDesign.mint
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
