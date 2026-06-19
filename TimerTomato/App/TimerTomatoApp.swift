//
//  TimerTomatoApp.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation
import SwiftUI
import SwiftData

@main
struct TimerTomatoApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var store: PomodoroStore

    private let modelContainer: ModelContainer

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    init() {
        let modelContainer = TimerTomatoModelContainer.makeDefault(
            isStoredInMemoryOnly: Self.isRunningTests
        )

        self.modelContainer = modelContainer
        _store = State(initialValue: PomodoroStore(modelContainer: modelContainer))
    }

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
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }

            store.refreshLifecycleState()
            store.refreshNotificationPermission()
        }

        Window("Checkliste", id: FocusChecklistWindowView.windowID) {
            FocusChecklistWindowView(store: store)
        }
        .windowResizability(.contentSize)
    }
}
