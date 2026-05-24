//
//  TimerTomatoDesign.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import AppKit
import SwiftUI

enum TimerTomatoDesign {
    static let heroCornerRadius: CGFloat = 26
    static let panelCornerRadius: CGFloat = 18
    static let rowCornerRadius: CGFloat = 14
    static let panelSpacing: CGFloat = 16
    static let contentWidth: CGFloat = 340
    static let historyContentWidth: CGFloat = contentWidth + 36
    static let contentPadding: CGFloat = 16
    static let cardBorderWidth: CGFloat = 1

    static let tomato = adaptiveColor(
        light: color(red: 0.82, green: 0.18, blue: 0.14),
        dark: color(red: 1.0, green: 0.36, blue: 0.30)
    )
    static let mint = adaptiveColor(
        light: color(red: 0.12, green: 0.58, blue: 0.46),
        dark: color(red: 0.26, green: 0.78, blue: 0.64)
    )
    static let success = adaptiveColor(
        light: color(red: 0.0, green: 0.72, blue: 0.28),
        dark: color(red: 0.28, green: 0.86, blue: 0.42)
    )
    static let surfaceFill = adaptiveColor(
        light: color(white: 1.0, alpha: 0.78),
        dark: color(white: 0.0, alpha: 0.28)
    )
    static let surfaceHighlight = adaptiveColor(
        light: color(white: 1.0, alpha: 0.72),
        dark: color(white: 1.0, alpha: 0.14)
    )
    static let surfaceMidline = adaptiveColor(
        light: color(white: 1.0, alpha: 0.22),
        dark: color(white: 1.0, alpha: 0.12)
    )
    static let cardBorder = adaptiveColor(
        light: color(white: 0.0, alpha: 0.10),
        dark: color(white: 1.0, alpha: 0.24)
    )
    static let surfaceLowlight = adaptiveColor(
        light: color(white: 0.0, alpha: 0.08),
        dark: color(white: 0.0, alpha: 0.46)
    )
    static let heroShadow = adaptiveColor(
        light: color(white: 0.0, alpha: 0.16),
        dark: color(white: 0.0, alpha: 0.45)
    )
    static let panelShadow = adaptiveColor(
        light: color(white: 0.0, alpha: 0.10),
        dark: color(white: 0.0, alpha: 0.32)
    )
    static let controlShadow = adaptiveColor(
        light: color(white: 0.0, alpha: 0.08),
        dark: color(white: 0.0, alpha: 0.24)
    )

    private static func adaptiveColor(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let bestMatch = appearance.bestMatch(from: [.darkAqua, .aqua])
            return bestMatch == .darkAqua ? dark : light
        })
    }

    private static func color(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> NSColor {
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }

    private static func color(white: CGFloat, alpha: CGFloat) -> NSColor {
        NSColor(calibratedWhite: white, alpha: alpha)
    }
}

extension View {
    func timerTomatoCardBorder(cornerRadius: CGFloat) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(TimerTomatoDesign.cardBorder, lineWidth: TimerTomatoDesign.cardBorderWidth)
                .allowsHitTesting(false)
        }
    }
}
