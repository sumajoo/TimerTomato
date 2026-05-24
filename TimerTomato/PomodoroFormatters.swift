//
//  PomodoroFormatters.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import Foundation

enum PomodoroFormatters {
    static func clockText(seconds: Int) -> String {
        let clampedSeconds = max(0, seconds)
        let hours = clampedSeconds / 3_600
        let minutes = (clampedSeconds % 3_600) / 60
        let seconds = clampedSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func minutesText(_ minutes: Int) -> String {
        "\(minutes) min"
    }

    static func pauseText(seconds: TimeInterval?) -> String {
        guard let seconds else {
            return "Erste Sitzung"
        }

        let minutes = max(0, Int(seconds.rounded()) / 60)

        if minutes == 0 {
            return "Pause unter 1 min"
        }

        return "Pause \(minutes) min"
    }

    static func todaySummaryText(
        sessions: Int,
        focusMinutes: Int,
        averagePauseSeconds: TimeInterval?
    ) -> String {
        let sessionText = sessions == 1 ? "1 Sitzung" : "\(sessions) Sitzungen"

        guard let averagePauseSeconds else {
            return "\(sessionText) · \(focusMinutes) min"
        }

        let averagePauseMinutes = max(0, Int(averagePauseSeconds.rounded()) / 60)
        return "\(sessionText) · \(focusMinutes) min · Ø Pause \(averagePauseMinutes) min"
    }
}
