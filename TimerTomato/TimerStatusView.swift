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
            "Bereit für Fokus"
        case .running:
            "Im Fokus"
        case .paused:
            "Fokus pausiert"
        }
    }

    var body: some View {
        VStack(spacing: 17) {
            VStack(spacing: 4) {
                Text(store.remainingClockText)
                    .font(.system(.largeTitle, design: .rounded).monospacedDigit())
                    .bold()
                    .contentTransition(.numericText())
                    .accessibilityLabel("Verbleibende Zeit \(store.remainingClockText)")

                Text(statusText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            TimerProgressBarView(progress: store.progress)

            TimerControlsView(store: store)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: TimerTomatoDesign.heroCornerRadius)
        )
    }
}
