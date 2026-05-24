//
//  TimerTomatoModelContainer.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftData

enum TimerTomatoModelContainer {
    @MainActor
    static func makeDefault() -> ModelContainer {
        do {
            return try make()
        } catch {
            fatalError("TimerTomato SwiftData container could not be created: \(error)")
        }
    }

    static func make(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            PomodoroSessionRecord.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
