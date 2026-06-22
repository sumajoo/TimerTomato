//
//  CompletionFeedbackView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import SwiftUI

struct CompletionFeedbackView: View {
    let feedback: PomodoroCompletionFeedback
    let canContinueFocus: Bool
    let continueFocus: (String) -> Void

    private var tint: Color {
        switch feedback.kind {
        case .focusWin, .momentum:
            TimerTomatoDesign.mint
        case .blocked:
            TimerTomatoDesign.tomato
        }
    }

    private var systemImage: String {
        switch feedback.kind {
        case .focusWin:
            "checkmark.circle.fill"
        case .momentum:
            "sparkles"
        case .blocked:
            "exclamationmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 9) {
            Label {
                VStack(alignment: .leading, spacing: 1) {
                    Text(feedback.title)
                        .font(.caption.bold())
                        .lineLimit(1)

                    Text(feedback.detail)
                        .font(.caption2)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
            }
            .labelStyle(.titleAndIcon)

            Spacer(minLength: 4)

            if let continuationIntent = feedback.continuationIntent, canContinueFocus {
                continueButton(intent: continuationIntent)
            }

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(tint.opacity(0.08))
                }
        }
        .accessibilityElement(children: .combine)
    }

    private func continueButton(intent: String) -> some View {
        let topicTitle = PomodoroFormatters.topicTitle(intent)

        return Button {
            continueFocus(intent)
        } label: {
            Label("Weiter mit \(topicTitle)", systemImage: "arrow.up.right")
                .font(.caption2.bold())
                .labelStyle(.titleAndIcon)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .foregroundStyle(TimerTomatoDesign.mint)
                .padding(.horizontal, 8)
                .frame(maxWidth: 136, minHeight: TimerTomatoDesign.minimumHitTarget)
                .contentShape(Capsule())
        }
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    Capsule()
                        .fill(TimerTomatoDesign.mint.opacity(0.10))
                }
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .buttonStyle(.plain)
        .help("Nächste Session mit \(topicTitle) starten")
    }
}

#if DEBUG
#Preview("Completion Feedback") {
    CompletionFeedbackView(
        feedback: PomodoroCompletionFeedback(
            kind: .focusWin,
            title: "+1 Session",
            detail: "Heute 3/3 · Woche 6/8",
            continuationIntent: "Lernen"
        ),
        canContinueFocus: true,
        continueFocus: { _ in }
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
