//
//  PomodoroStatus.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

enum PomodoroStatus: String, Codable, Equatable {
    case idle
    case running
    case paused
}
