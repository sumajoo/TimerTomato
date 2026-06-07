//
//  FocusOutcomePromptView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import SwiftUI

struct FocusOutcomePromptView: View {
    @State private var isShowingBlockerFollowUp = false
    @State private var isShowingBlockerReasons = false
    @State private var blockerReason: PomodoroBlockerReason?
    @State private var blockerNextStep = ""

    let session: PomodoroSession
    let complete: (PomodoroSessionOutcome, PomodoroBlockerReason?, String?) -> Void

    private var firstReasonRow: [PomodoroBlockerReason] {
        Array(PomodoroBlockerReason.allCases.prefix(3))
    }

    private var secondReasonRow: [PomodoroBlockerReason] {
        Array(PomodoroBlockerReason.allCases.suffix(2))
    }

    private var titleText: String {
        session.intentTitle ?? "Fokus abgeschlossen"
    }

    var body: some View {
        VStack(spacing: 8) {
            Label(titleText, systemImage: "flag.checkered")
                .font(.caption)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .labelStyle(.titleAndIcon)
                .lineLimit(1)

            Text("Was ist passiert?")
                .font(.caption.bold())
                .foregroundStyle(.primary)
                .lineLimit(1)

            if isShowingBlockerFollowUp {
                blockerFollowUp
            } else {
                outcomeButtons
            }
        }
        .onChange(of: session.id) {
            resetBlockerFollowUp()
        }
    }

    private var outcomeButtons: some View {
        HStack(spacing: 6) {
            ForEach(PomodoroSessionOutcome.allCases, id: \.self) { outcome in
                Button {
                    select(outcome)
                } label: {
                    Label(outcome.title, systemImage: outcome.systemImage)
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(tint(for: outcome))
                        .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
                        .contentShape(Capsule())
                }
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                        .overlay {
                            Capsule()
                                .fill(tint(for: outcome).opacity(0.10))
                        }
                }
                .glassEffect(.regular.interactive(), in: .capsule)
                .buttonStyle(.plain)
                .help(outcome.title)
            }
        }
    }

    private var blockerFollowUp: some View {
        VStack(spacing: 7) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.caption)
                    .foregroundStyle(TimerTomatoDesign.tomato)
                    .accessibilityHidden(true)

                TextField("Kleinster nächster Schritt", text: $blockerNextStep)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .frame(minHeight: TimerTomatoDesign.minimumHitTarget)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
            }
            .glassEffect(.regular.interactive(), in: .capsule)

            if isShowingBlockerReasons {
                reasonRow(firstReasonRow)
                reasonRow(secondReasonRow)
            } else {
                Button {
                    isShowingBlockerReasons = true
                } label: {
                    Label("Grund hinzufügen", systemImage: "tag")
                        .font(.caption.bold())
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.compactHitTarget)
                        .contentShape(Capsule())
                }
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(.regular.interactive(), in: .capsule)
                .buttonStyle(.plain)
                .help("Optionalen Blockade-Grund auswählen")
            }

            HStack(spacing: 7) {
                Button {
                    complete(.blocked, nil, nil)
                } label: {
                    Text("Überspringen")
                        .font(.caption.bold())
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
                        .contentShape(Capsule())
                }
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(.regular.interactive(), in: .capsule)
                .buttonStyle(.plain)
                .help("Blockade ohne Details speichern")

                Button {
                    complete(.blocked, blockerReason, blockerNextStep)
                } label: {
                    Label("Speichern", systemImage: "checkmark")
                        .font(.caption.bold())
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(TimerTomatoDesign.mint)
                        .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
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
                .help("Blockade speichern")
            }
        }
    }

    private func reasonRow(_ reasons: [PomodoroBlockerReason]) -> some View {
        HStack(spacing: 6) {
            ForEach(reasons, id: \.self) { reason in
                reasonButton(reason)
            }
        }
    }

    private func reasonButton(_ reason: PomodoroBlockerReason) -> some View {
        let isSelected = blockerReason == reason

        return Button {
            blockerReason = isSelected ? nil : reason
        } label: {
            Label(reason.shortTitle, systemImage: reason.systemImage)
                .font(.caption2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .labelStyle(.titleAndIcon)
                .foregroundStyle(isSelected ? TimerTomatoDesign.tomato : TimerTomatoDesign.secondaryText)
                .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
                .contentShape(Capsule())
        }
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    if isSelected {
                        Capsule()
                            .fill(TimerTomatoDesign.tomato.opacity(0.12))
                    }
                }
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .buttonStyle(.plain)
        .help(reason.title)
    }

    private func select(_ outcome: PomodoroSessionOutcome) {
        if outcome == .blocked {
            isShowingBlockerFollowUp = true
        } else {
            complete(outcome, nil, nil)
        }
    }

    private func resetBlockerFollowUp() {
        isShowingBlockerFollowUp = false
        isShowingBlockerReasons = false
        blockerReason = nil
        blockerNextStep = ""
    }

    private func tint(for outcome: PomodoroSessionOutcome) -> Color {
        outcome == .blocked ? TimerTomatoDesign.tomato : TimerTomatoDesign.mint
    }
}

#if DEBUG
#Preview("Outcome Prompt") {
    FocusOutcomePromptView(
        session: TimerTomatoPreviewData.sampleSession,
        complete: { _, _, _ in }
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
