//
//  TimerStatusView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerStatusView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var completionFeedback: PomodoroCompletionFeedback?
    @State private var feedbackDismissTask: Task<Void, Never>?

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

                TimerProgressBarView(
                    progress: store.progress,
                    tint: accentColor,
                    heatIntensity: focusHeatIntensity
                )

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
                    if let completionFeedback {
                        CompletionFeedbackView(
                            feedback: completionFeedback,
                            canStartRescue: store.canStartFocus,
                            startRescue: startRescueFromFeedback
                        )
                    }

                    TimerControlsView(store: store)
                }
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
        .onDisappear {
            feedbackDismissTask?.cancel()
            feedbackDismissTask = nil
        }
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
        showCompletionFeedback(store.completionFeedback(for: session, outcome: outcome))
    }

    private func showCompletionFeedback(_ feedback: PomodoroCompletionFeedback) {
        feedbackDismissTask?.cancel()
        completionFeedback = feedback
        feedbackDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            guard !Task.isCancelled else {
                return
            }

            completionFeedback = nil
            feedbackDismissTask = nil
        }
    }

    private func startRescueFromFeedback() {
        feedbackDismissTask?.cancel()
        feedbackDismissTask = nil
        completionFeedback = nil
        store.startRescueFocus()
    }
}

private struct FocusHeatBackground: View {
    let intensity: Double

    private var clampedIntensity: Double {
        min(max(intensity, 0), 1)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: TimerTomatoDesign.heroCornerRadius, style: .continuous)
            .fill(TimerTomatoDesign.tomato.opacity(0.05 * clampedIntensity))
            .allowsHitTesting(false)
    }
}

private struct FocusHeatBorder: View {
    let intensity: Double

    private var clampedIntensity: Double {
        min(max(intensity, 0), 1)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: TimerTomatoDesign.heroCornerRadius, style: .continuous)
            .stroke(TimerTomatoDesign.tomato.opacity(0.22 * clampedIntensity), lineWidth: TimerTomatoDesign.cardBorderWidth)
            .shadow(color: TimerTomatoDesign.tomato.opacity(0.16 * clampedIntensity), radius: 10, x: 0, y: 0)
            .allowsHitTesting(false)
    }
}

private struct FocusIntentView: View {
    @FocusState private var isIntentFieldFocused: Bool

    @Bindable var store: PomodoroStore

    private var normalizedIntent: String? {
        PomodoroSession.normalizedIntent(store.pendingFocusIntent)
    }

    private var isCustomIntentActive: Bool {
        guard let normalizedIntent else {
            return isIntentFieldFocused
        }

        return isIntentFieldFocused || !PomodoroStore.focusIntentSuggestions.contains(normalizedIntent)
    }

    var body: some View {
        VStack(spacing: 6) {
            VStack(spacing: 5) {
                HStack(spacing: 6) {
                    ForEach(Array(PomodoroStore.focusIntentSuggestions.prefix(3)), id: \.self) { suggestion in
                        intentChip(suggestion)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(Array(PomodoroStore.focusIntentSuggestions.suffix(1)), id: \.self) { suggestion in
                        intentChip(suggestion)
                    }

                    customIntentChip
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
                    .focused($isIntentFieldFocused)

                if normalizedIntent != nil {
                    Button("Ziel leeren", systemImage: "xmark.circle.fill", action: store.clearFocusIntent)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .foregroundStyle(TimerTomatoDesign.tertiaryText)
                        .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                        .help("Fokus-Ziel leeren")
                }
            }
            .padding(.horizontal, 10)
            .frame(height: TimerTomatoDesign.compactHitTarget)
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
            isIntentFieldFocused = false
        }
        .font(.caption2)
        .fontWeight(isSelected ? .semibold : .medium)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
        .frame(height: 24)
        .padding(.horizontal, 10)
        .background { intentChipBackground(isActive: isSelected) }
        .glassEffect(.regular.interactive(), in: .capsule)
        .timerTomatoHitTarget(minWidth: 64, minHeight: TimerTomatoDesign.compactHitTarget)
        .buttonStyle(.plain)
        .help("Fokus-Ziel \(suggestion)")
    }

    private var customIntentChip: some View {
        Button("Eigenes Ziel", systemImage: "square.and.pencil") {
            isIntentFieldFocused = true
        }
        .font(.caption2)
        .fontWeight(isCustomIntentActive ? .semibold : .medium)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .labelStyle(.titleAndIcon)
        .foregroundStyle(isCustomIntentActive ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
        .frame(height: 24)
        .padding(.horizontal, 10)
        .background { intentChipBackground(isActive: isCustomIntentActive) }
        .glassEffect(.regular.interactive(), in: .capsule)
        .timerTomatoHitTarget(minWidth: 108, minHeight: TimerTomatoDesign.compactHitTarget)
        .buttonStyle(.plain)
        .help("Eigenes Fokus-Ziel eingeben")
    }

    private func intentChipBackground(isActive: Bool) -> some View {
        Capsule()
            .fill(TimerTomatoDesign.surfaceFill)
            .overlay {
                Capsule()
                    .strokeBorder(
                        TimerTomatoDesign.mint.opacity(isActive ? 0.42 : 0.16),
                        lineWidth: isActive ? 0.9 : 0.7
                    )
            }
    }
}

private struct FocusOutcomePromptView: View {
    @State private var isShowingBlockerFollowUp = false
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
                Button(outcome.title, systemImage: outcome.systemImage) {
                    select(outcome)
                }
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .labelStyle(.titleAndIcon)
                .foregroundStyle(tint(for: outcome))
                .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
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
            reasonRow(firstReasonRow)
            reasonRow(secondReasonRow)

            HStack(spacing: 6) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.caption)
                    .foregroundStyle(TimerTomatoDesign.tomato)
                    .accessibilityHidden(true)

                TextField("Nächster Schritt", text: $blockerNextStep)
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

            HStack(spacing: 7) {
                Button("Überspringen") {
                    complete(.blocked, nil, nil)
                }
                .font(.caption.bold())
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(.regular.interactive(), in: .capsule)
                .buttonStyle(.plain)
                .help("Blockade ohne Details speichern")

                Button("Speichern", systemImage: "checkmark") {
                    complete(.blocked, blockerReason, blockerNextStep)
                }
                .font(.caption.bold())
                .labelStyle(.titleAndIcon)
                .foregroundStyle(TimerTomatoDesign.mint)
                .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
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

        return Button(reason.shortTitle, systemImage: reason.systemImage) {
            blockerReason = isSelected ? nil : reason
        }
        .font(.caption2.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.74)
        .labelStyle(.titleAndIcon)
        .foregroundStyle(isSelected ? TimerTomatoDesign.tomato : TimerTomatoDesign.secondaryText)
        .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
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
        blockerReason = nil
        blockerNextStep = ""
    }

    private func tint(for outcome: PomodoroSessionOutcome) -> Color {
        outcome == .blocked ? TimerTomatoDesign.tomato : TimerTomatoDesign.mint
    }
}

private struct CompletionFeedbackView: View {
    let feedback: PomodoroCompletionFeedback
    let canStartRescue: Bool
    let startRescue: () -> Void

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

            if feedback.offersRescueAction && canStartRescue {
                Button("10-min Reset", systemImage: "bolt.fill", action: startRescue)
                    .font(.caption2.bold())
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .padding(.horizontal, 8)
                    .frame(minHeight: TimerTomatoDesign.minimumHitTarget)
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
                    .help("10 Minuten Reset starten")
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
