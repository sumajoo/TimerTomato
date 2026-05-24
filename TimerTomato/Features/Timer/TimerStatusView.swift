//
//  TimerStatusView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerStatusView: View {
    @Bindable var store: PomodoroStore

    private var accentColor: Color {
        store.activeTimerKind == .breakTime ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    private var statusText: String {
        switch store.status {
        case .idle:
            store.canStartBreak ? "Bereit für Fokus oder Pause" : "Bereit für Fokus"
        case .running:
            store.activeTimerKind == .breakTime ? "Pause läuft" : "Im Fokus"
        case .paused:
            store.activeTimerKind == .breakTime ? "Pause pausiert" : "Fokus pausiert"
        }
    }

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(spacing: 17) {
                VStack(spacing: 4) {
                    Text(store.remainingClockText)
                        .font(.system(.largeTitle, design: .rounded).monospacedDigit())
                        .bold()
                        .contentTransition(.numericText())
                        .accessibilityLabel("Verbleibende Zeit \(store.remainingClockText)")

                    Text(statusText)
                        .font(.callout)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)

                    if let notificationWarningText = store.notificationWarningText {
                        Label(notificationWarningText, systemImage: "bell.slash")
                            .font(.caption)
                            .foregroundStyle(TimerTomatoDesign.tertiaryText)
                            .labelStyle(.titleAndIcon)
                    }

                    if store.activeTimerKind == .focus, let activeFocusIntent = store.activeFocusIntentText {
                        Label("Jetzt: \(activeFocusIntent)", systemImage: "target")
                            .font(.caption)
                            .foregroundStyle(TimerTomatoDesign.mint)
                            .labelStyle(.titleAndIcon)
                            .lineLimit(1)
                    }
                }

                if store.status == .idle && !store.hasPendingOutcome {
                    FocusIntentView(store: store)
                }

                TimerProgressBarView(progress: store.progress, tint: accentColor)

                if let pendingOutcomeSession = store.pendingOutcomeSession {
                    FocusOutcomePromptView(
                        session: pendingOutcomeSession,
                        complete: store.completePendingOutcome
                    )
                } else {
                    TimerControlsView(store: store)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 18)
            .timerTomatoCard(.hero)
        }
    }
}

private struct FocusIntentView: View {
    @Bindable var store: PomodoroStore

    private var normalizedIntent: String? {
        PomodoroSession.normalizedIntent(store.pendingFocusIntent)
    }

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 5) {
                ForEach(PomodoroStore.focusIntentSuggestions, id: \.self) { suggestion in
                    intentChip(suggestion)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.caption)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .accessibilityHidden(true)

                TextField("Eigenes Ziel", text: $store.pendingFocusIntent)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .lineLimit(1)

                if normalizedIntent != nil {
                    Button("Ziel leeren", systemImage: "xmark.circle.fill", action: store.clearFocusIntent)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .foregroundStyle(TimerTomatoDesign.tertiaryText)
                        .help("Fokus-Ziel leeren")
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
            }
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .accessibilityElement(children: .contain)
    }

    private func intentChip(_ suggestion: String) -> some View {
        let isSelected = normalizedIntent == suggestion

        return Button(suggestion) {
            store.selectFocusIntentSuggestion(suggestion)
        }
        .font(.caption2)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    if isSelected {
                        Capsule()
                            .fill(TimerTomatoDesign.mint.opacity(0.14))
                    }
                }
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .buttonStyle(.plain)
        .help("Fokus-Ziel \(suggestion)")
    }
}

private struct FocusOutcomePromptView: View {
    let session: PomodoroSession
    let complete: (PomodoroSessionOutcome) -> Void

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

            HStack(spacing: 6) {
                ForEach(PomodoroSessionOutcome.allCases, id: \.self) { outcome in
                    Button(outcome.title, systemImage: outcome.systemImage) {
                        complete(outcome)
                    }
                    .font(.caption.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(tint(for: outcome))
                    .frame(maxWidth: .infinity, minHeight: 30)
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
    }

    private func tint(for outcome: PomodoroSessionOutcome) -> Color {
        outcome == .blocked ? TimerTomatoDesign.tomato : TimerTomatoDesign.mint
    }
}

#if DEBUG
#Preview("Timer Status") {
    TimerStatusView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
