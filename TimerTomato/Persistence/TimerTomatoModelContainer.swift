//
//  TimerTomatoModelContainer.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftData

enum TimerTomatoModelContainer {
    static let cloudKitContainerIdentifier = "iCloud.com.jonasbecker.TimerTomato"

    @MainActor
    static func makeDefault(isStoredInMemoryOnly: Bool = false) -> ModelContainer {
        do {
            return try make(isStoredInMemoryOnly: isStoredInMemoryOnly)
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
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            cloudKitDatabase: isStoredInMemoryOnly ? .none : .private(cloudKitContainerIdentifier)
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
