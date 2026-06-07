//
//  TimerStatusView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerStatusView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Bindable var store: PomodoroStore

    private var accentColor: Color {
        store.activeTimerKind == .breakTime ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    private var focusHeatIntensity: Double {
        store.focusHeatIntensity
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
            VStack(spacing: 14) {
                statusHeader
                idleIntentInput
                activeProgress
                completionArea
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 16)
            .background {
                FocusHeatBackground(intensity: focusHeatIntensity)
            }
            .timerTomatoCard(.hero)
            .overlay {
                FocusHeatBorder(intensity: focusHeatIntensity)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: focusHeatIntensity)
        }
    }

    private var statusHeader: some View {
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

            if store.canChangeActiveFocusIntent {
                ActiveFocusTopicView(store: store)
            }

            if let activeChecklistCue = store.activeChecklistCue {
                activeChecklistCueView(activeChecklistCue)
            }
        }
    }

    @ViewBuilder
    private var idleIntentInput: some View {
        if store.status == .idle && !store.hasPendingOutcome {
            FocusIntentView(store: store)
        }
    }

    @ViewBuilder
    private var activeProgress: some View {
        if store.status != .idle {
            TimerProgressBarView(
                progress: store.progress,
                tint: accentColor,
                heatIntensity: focusHeatIntensity
            )
        }
    }

    @ViewBuilder
    private var completionArea: some View {
        if let pendingOutcomeSession = store.pendingOutcomeSession {
            FocusOutcomePromptView(
                session: pendingOutcomeSession,
                complete: { outcome, blockerReason, blockerNextStep in
                    completeOutcome(
                        outcome,
                        blockerReason: blockerReason,
                        blockerNextStep: blockerNextStep,
                        session: pendingOutcomeSession
                    )
                }
            )
        } else {
            TimerControlsView(store: store)
        }
    }

    private func activeChecklistCueView(_ cue: PomodoroChecklistCue) -> some View {
        Label {
            Text("\(cue.timeText): \(cue.title)")
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        } icon: {
            Image(systemName: cue.isDue ? "checklist.checked" : "checklist")
                .foregroundStyle(cue.isDue ? TimerTomatoDesign.mint : TimerTomatoDesign.tertiaryText)
        }
        .font(.caption)
        .foregroundStyle(TimerTomatoDesign.secondaryText)
        .labelStyle(.titleAndIcon)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.compactHitTarget)
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .accessibilityLabel("Nächster Checklistenpunkt \(cue.timeText), \(cue.title)")
    }

    private func completeOutcome(
        _ outcome: PomodoroSessionOutcome,
        blockerReason: PomodoroBlockerReason?,
        blockerNextStep: String?,
        session: PomodoroSession
    ) {
        store.completePendingOutcome(
            outcome,
            blockerReason: blockerReason,
            blockerNextStep: blockerNextStep
        )
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
