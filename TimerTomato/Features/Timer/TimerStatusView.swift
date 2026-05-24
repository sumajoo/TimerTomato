//
//  TimerStatusView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerStatusView: View {
    let store: PomodoroStore

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
                }

                TimerProgressBarView(progress: store.progress, tint: accentColor)

                TimerControlsView(store: store)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 18)
            .timerTomatoCard(.hero)
        }
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
