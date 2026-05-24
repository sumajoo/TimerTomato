//
//  TimerControlsView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerControlsView: View {
    let store: PomodoroStore

    var body: some View {
        HStack(spacing: 8) {
            switch store.status {
            case .idle:
                Button("Fokus starten", systemImage: "play.fill", action: store.start)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
            case .running:
                Button("Pause", systemImage: "pause.fill", action: store.pause)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glass)
            case .paused:
                Button("Fortsetzen", systemImage: "play.fill", action: store.resume)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
            }

            if store.status != .idle {
                Button("Zurücksetzen", systemImage: "arrow.counterclockwise", action: store.reset)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .help("Zurücksetzen")
            }
        }
        .tint(TimerTomatoDesign.tomato)
    }
}
