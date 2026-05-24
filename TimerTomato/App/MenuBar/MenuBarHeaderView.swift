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
    let showHistory: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Label {
                Text("TimerTomato")
            } icon: {
                Text("🍅")
                    .font(.title3)
                    .accessibilityHidden(true)
            }
                .font(.headline)
                .labelStyle(.titleAndIcon)

            Spacer()

            Text(store.compactTodaySummaryText)
                .font(.callout.monospacedDigit())
                .foregroundStyle(TimerTomatoDesign.secondaryText)

            Button("Verlauf", systemImage: "calendar", action: showHistory)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
                .buttonStyle(.plain)
                .help("Verlauf öffnen")

            Button("Beenden", systemImage: "power", action: quit)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
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

#if DEBUG
#Preview("Menübar Header") {
    MenuBarHeaderView(
        store: TimerTomatoPreviewData.store(),
        showHistory: {}
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
