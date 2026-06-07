//
//  PomodoroChecklist.swift
//  TimerTomato
//
//  Created by Jonas Becker on 06.06.26.
//

import Foundation

enum PomodoroChecklistReminderMode: String, Codable, CaseIterable, Identifiable {
    case off
    case quiet
    case normal

    nonisolated var id: String {
        rawValue
    }

    nonisolated var title: String {
        switch self {
        case .off:
            "Aus"
        case .quiet:
            "Leise"
        case .normal:
            "Normal"
        }
    }
}

struct PomodoroChecklistCue: Equatable {
    let title: String
    let timeText: String
    let isDue: Bool

    nonisolated init(item: PomodoroChecklistItem, elapsedSeconds: TimeInterval) {
        let reminderSeconds = TimeInterval(item.reminderMinuteOffset * 60)
        let secondsUntilReminder = reminderSeconds - elapsedSeconds
        let minutesUntilReminder = Int(ceil(max(secondsUntilReminder, 0) / 60))

        title = item.title
        isDue = secondsUntilReminder <= 0
        timeText = isDue ? "Jetzt" : "In \(max(minutesUntilReminder, 1)) min"
    }
}

struct PomodoroChecklistItem: Identifiable, Codable, Equatable {
    nonisolated static let maximumTitleCharacters = 120
    nonisolated static let maximumReminderMinuteOffset = 90

    let id: UUID
    var title: String
    var reminderMinuteOffset: Int
    var isCompleted: Bool

    nonisolated init(
        id: UUID = UUID(),
        title: String,
        reminderMinuteOffset: Int = 0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = Self.normalizedTitle(title)
        self.reminderMinuteOffset = Self.normalizedReminderMinuteOffset(reminderMinuteOffset)
        self.isCompleted = isCompleted
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = Self.normalizedTitle(try container.decode(String.self, forKey: .title))
        reminderMinuteOffset = Self.normalizedReminderMinuteOffset(
            try container.decodeIfPresent(Int.self, forKey: .reminderMinuteOffset) ?? 0
        )
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }

    nonisolated static func normalizedTitle(_ title: String) -> String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.count > maximumTitleCharacters {
            return String(trimmedTitle.prefix(maximumTitleCharacters))
        }

        return trimmedTitle
    }

    nonisolated static func normalizedReminderMinuteOffset(_ minuteOffset: Int) -> Int {
        min(max(minuteOffset, 0), maximumReminderMinuteOffset)
    }

    nonisolated static func reminderTimeText(for minuteOffset: Int) -> String {
        let normalizedMinuteOffset = normalizedReminderMinuteOffset(minuteOffset)

        if normalizedMinuteOffset == 0 {
            return "Jetzt"
        }

        return "\(normalizedMinuteOffset) min"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case reminderMinuteOffset
        case isCompleted
    }
}

struct PomodoroChecklist: Codable, Equatable {
    nonisolated static let maximumItems = 8
    nonisolated static let learningGoal = "Lernen"
    nonisolated static let learningDefaultTitles = [
        "Buch öffnen",
        "Inhalt lesen",
        "3 Minuten laut sagen \"Worum geht es hier überhaupt\"",
        "3 Stichpunkte machen"
    ]
    nonisolated static let learningDefaultReminderMinuteOffsets = [0, 1, 3, 6]
    nonisolated static let learningDefaultItems = [
        PomodoroChecklistItem(
            id: UUID(uuidString: "11111111-1111-4111-8111-111111111111") ?? UUID(),
            title: learningDefaultTitles[0],
            reminderMinuteOffset: learningDefaultReminderMinuteOffsets[0]
        ),
        PomodoroChecklistItem(
            id: UUID(uuidString: "22222222-2222-4222-8222-222222222222") ?? UUID(),
            title: learningDefaultTitles[1],
            reminderMinuteOffset: learningDefaultReminderMinuteOffsets[1]
        ),
        PomodoroChecklistItem(
            id: UUID(uuidString: "33333333-3333-4333-8333-333333333333") ?? UUID(),
            title: learningDefaultTitles[2],
            reminderMinuteOffset: learningDefaultReminderMinuteOffsets[2]
        ),
        PomodoroChecklistItem(
            id: UUID(uuidString: "44444444-4444-4444-8444-444444444444") ?? UUID(),
            title: learningDefaultTitles[3],
            reminderMinuteOffset: learningDefaultReminderMinuteOffsets[3]
        )
    ]

    let goal: String
    var reminderMode: PomodoroChecklistReminderMode
    var items: [PomodoroChecklistItem]

    nonisolated var isEmpty: Bool {
        items.isEmpty
    }

    nonisolated init(
        goal: String,
        items: [PomodoroChecklistItem] = [],
        reminderMode: PomodoroChecklistReminderMode = .normal
    ) {
        self.goal = PomodoroSession.normalizedIntent(goal) ?? ""
        self.reminderMode = reminderMode
        self.items = Array(items.prefix(Self.maximumItems)).map { item in
            PomodoroChecklistItem(
                id: item.id,
                title: item.title,
                reminderMinuteOffset: item.reminderMinuteOffset,
                isCompleted: item.isCompleted
            )
        }
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        goal = PomodoroSession.normalizedIntent(try container.decode(String.self, forKey: .goal)) ?? ""
        reminderMode = try container.decodeIfPresent(PomodoroChecklistReminderMode.self, forKey: .reminderMode) ?? .normal
        items = Array(
            try container.decodeIfPresent([PomodoroChecklistItem].self, forKey: .items) ?? []
        )
        .prefix(Self.maximumItems)
        .map { item in
            PomodoroChecklistItem(
                id: item.id,
                title: item.title,
                reminderMinuteOffset: item.reminderMinuteOffset,
                isCompleted: item.isCompleted
            )
        }
    }

    nonisolated func resettingCompletions() -> PomodoroChecklist {
        PomodoroChecklist(
            goal: goal,
            items: items.map { item in
                PomodoroChecklistItem(
                    id: item.id,
                    title: item.title,
                    reminderMinuteOffset: item.reminderMinuteOffset
                )
            },
            reminderMode: reminderMode
        )
    }

    nonisolated func asTemplate() -> PomodoroChecklist {
        resettingCompletions()
    }

    nonisolated static func defaultTemplate(for goal: String) -> PomodoroChecklist {
        let normalizedGoal = PomodoroSession.normalizedIntent(goal) ?? ""

        guard normalizedGoal == learningGoal else {
            return PomodoroChecklist(goal: normalizedGoal)
        }

        return PomodoroChecklist(
            goal: normalizedGoal,
            items: learningDefaultItems,
            reminderMode: .normal
        )
    }

    private enum CodingKeys: String, CodingKey {
        case goal
        case reminderMode
        case items
    }
}
