//
//  TimerTomatoApp.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

@main
struct TimerTomatoApp: App {
    @State private var store = PomodoroStore()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(store: store)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: store.menuBarSystemImage)

                Text(store.menuBarTitle)
                    .monospacedDigit()
            }
            .accessibilityLabel(store.menuBarAccessibilityLabel)
        }
        .menuBarExtraStyle(.window)
    }
}
