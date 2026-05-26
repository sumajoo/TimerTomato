//
//  TimerControlsView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerControlsView: View {
    @Namespace private var glassNamespace

    let store: PomodoroStore

    private var accentColor: Color {
        store.activeTimerKind == .breakTime ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    private var primaryButtonWidth: CGFloat {
        store.status == .idle && store.canStartBreak ? 154 : store.status == .idle ? 180 : 138
    }

    var body: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)

            switch store.status {
            case .idle:
                Button("Fokus starten", systemImage: "play.fill", action: store.start)
                    .frame(width: primaryButtonWidth)
                    .timerTomatoHitTarget(minWidth: primaryButtonWidth)
                    .buttonStyle(.glassProminent)
                    .tint(TimerTomatoDesign.tomato)
                    .disabled(!store.canStartFocus)
                    .glassEffectID("timer-primary-control", in: glassNamespace)

                if store.canStartBreak {
                    Button("Pause starten", systemImage: "cup.and.saucer.fill", action: store.startBreak)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.glass)
                        .foregroundStyle(TimerTomatoDesign.mint)
                        .frame(width: TimerTomatoDesign.minimumHitTarget, height: TimerTomatoDesign.minimumHitTarget)
                        .help("5 Minuten Pause starten")
                        .glassEffectID("timer-break-control", in: glassNamespace)
                }
            case .running:
                Button("Pause", systemImage: "pause.fill", action: store.pause)
                    .frame(width: primaryButtonWidth)
                    .timerTomatoHitTarget(minWidth: primaryButtonWidth)
                    .buttonStyle(.glassProminent)
                    .tint(accentColor)
                    .glassEffectID("timer-primary-control", in: glassNamespace)
            case .paused:
                Button("Fortsetzen", systemImage: "play.fill", action: store.resume)
                    .frame(width: primaryButtonWidth)
                    .timerTomatoHitTarget(minWidth: primaryButtonWidth)
                    .buttonStyle(.glassProminent)
                    .tint(accentColor)
                    .glassEffectID("timer-primary-control", in: glassNamespace)
            }

            if store.status != .idle {
                Button("Zurücksetzen", systemImage: "arrow.counterclockwise", action: store.reset)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .frame(width: TimerTomatoDesign.minimumHitTarget, height: TimerTomatoDesign.minimumHitTarget)
                    .help("Zurücksetzen")
                    .glassEffectID("timer-reset-control", in: glassNamespace)
            }

            Spacer(minLength: 0)
        }
    }
}

#if DEBUG
#Preview("Timer Controls") {
    TimerControlsView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
