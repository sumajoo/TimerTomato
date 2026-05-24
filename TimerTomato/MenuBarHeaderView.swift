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
                .imageScale(.medium)

            Spacer()

            Text("\(store.focusMinutesToday) min heute")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)

            Button("Beenden", systemImage: "power", action: quit)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
                .buttonStyle(.plain)
                .help("TimerTomato beenden")
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
