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

            TimerProgressBarView(progress: store.progress, tint: accentColor)

            TimerControlsView(store: store)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .background {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.heroCornerRadius)
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: TimerTomatoDesign.heroCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.heroCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            TimerTomatoDesign.surfaceHighlight,
                            TimerTomatoDesign.surfaceMidline,
                            TimerTomatoDesign.surfaceLowlight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.9
                )
        }
        .shadow(color: TimerTomatoDesign.heroShadow, radius: 28, x: 0, y: 18)
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
