//
//  TimerStatusView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerStatusView: View {
    let store: PomodoroStore

    private var statusText: String {
        switch store.status {
        case .idle:
            "Fokus · bereit"
        case .running:
            "Fokus · läuft"
        case .paused:
            "Fokus · pausiert"
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            Text(store.remainingClockText)
                .font(.system(.largeTitle, design: .rounded).monospacedDigit())
                .bold()
                .contentTransition(.numericText())
                .accessibilityLabel("Verbleibende Zeit \(store.remainingClockText)")

            Label(statusText, systemImage: store.menuBarSystemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TimerProgressBarView(progress: store.progress)

            TimerControlsView(store: store)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .tint(TimerTomatoDesign.tomato)
        .glassEffect(
            .regular.tint(TimerTomatoDesign.timerTint),
            in: .rect(cornerRadius: TimerTomatoDesign.panelCornerRadius)
        )
    }
}
