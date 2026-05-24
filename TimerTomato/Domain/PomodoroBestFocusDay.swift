//
//  PomodoroBestFocusDay.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

struct PomodoroBestFocusDay: Identifiable, Equatable {
    let date: Date
    let sessionCount: Int
    let focusMinutes: Int

    var id: Date {
        date
    }
}
