//
//  MenuBarHeaderView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import AppKit
import SwiftUI

struct MenuBarHeaderView: View {
    let store: PomodoroStore

    var body: some View {
        HStack(alignment: .center) {
            Label("TimerTomato", systemImage: "timer")
                .font(.headline)
                .labelStyle(.titleAndIcon)

            Spacer()

            Text("\(store.focusMinutesToday) min heute")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)

            Button("Beenden", systemImage: "power", action: quit)
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .help("TimerTomato beenden")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(
            .regular.tint(TimerTomatoDesign.neutralTint),
            in: .rect(cornerRadius: TimerTomatoDesign.panelCornerRadius)
        )
        .accessibilityElement(children: .contain)
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
