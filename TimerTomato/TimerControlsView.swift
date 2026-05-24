//
//  TimerControlsView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerControlsView: View {
    let store: PomodoroStore

    private var primaryButtonWidth: CGFloat {
        store.status == .idle ? 180 : 138
    }

    var body: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)

            switch store.status {
            case .idle:
                Button("Fokus starten", systemImage: "play.fill", action: store.start)
                    .frame(width: primaryButtonWidth)
                    .buttonStyle(.glassProminent)
                    .tint(TimerTomatoDesign.tomato)
            case .running:
                Button("Pause", systemImage: "pause.fill", action: store.pause)
                    .frame(width: primaryButtonWidth)
                    .buttonStyle(.glassProminent)
                    .tint(TimerTomatoDesign.tomato)
            case .paused:
                Button("Fortsetzen", systemImage: "play.fill", action: store.resume)
                    .frame(width: primaryButtonWidth)
                    .buttonStyle(.glassProminent)
                    .tint(TimerTomatoDesign.tomato)
            }

            if store.status != .idle {
                Button("Zurücksetzen", systemImage: "arrow.counterclockwise", action: store.reset)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .foregroundStyle(.secondary)
                    .frame(width: 38)
                    .help("Zurücksetzen")
            }

            Spacer(minLength: 0)
        }
    }
}
