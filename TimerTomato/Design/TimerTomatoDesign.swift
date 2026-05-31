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
    static let minimumHitTarget: CGFloat = 44
    static let compactHitTarget: CGFloat = 34

    static let tomato = adaptiveColor(
        light: color(red: 0.82, green: 0.18, blue: 0.14),
        dark: color(red: 0.94, green: 0.32, blue: 0.27)
    )
    static let mint = adaptiveColor(
        light: color(red: 0.12, green: 0.58, blue: 0.46),
        dark: color(red: 0.22, green: 0.72, blue: 0.60)
    )
    static let success = adaptiveColor(
        light: color(red: 0.0, green: 0.72, blue: 0.28),
        dark: color(red: 0.20, green: 0.78, blue: 0.34)
    )
    static let surfaceFill = adaptiveColor(
        light: color(white: 1.0, alpha: 0.78),
        dark: color(white: 1.0, alpha: 0.05)
    )
    static let surfaceHighlight = adaptiveColor(
        light: color(white: 1.0, alpha: 0.72),
        dark: color(white: 1.0, alpha: 0.16)
    )
    static let surfaceMidline = adaptiveColor(
        light: color(white: 1.0, alpha: 0.22),
        dark: color(white: 1.0, alpha: 0.10)
    )
    static let cardBorder = adaptiveColor(
        light: color(white: 0.0, alpha: 0.10),
        dark: color(white: 1.0, alpha: 0.20)
    )
    static let surfaceLowlight = adaptiveColor(
        light: color(white: 0.0, alpha: 0.08),
        dark: color(white: 0.0, alpha: 0.30)
    )
    static let secondaryText = adaptiveColor(
        light: color(white: 0.0, alpha: 0.60),
        dark: color(white: 1.0, alpha: 0.68)
    )
    static let tertiaryText = adaptiveColor(
        light: color(white: 0.0, alpha: 0.38),
        dark: color(white: 1.0, alpha: 0.44)
    )
    static let trackFill = adaptiveColor(
        light: color(white: 0.0, alpha: 0.12),
        dark: color(white: 1.0, alpha: 0.14)
    )
    static let heroShadow = adaptiveColor(
        light: color(white: 0.0, alpha: 0.16),
        dark: color(white: 0.0, alpha: 0.32)
    )
    static let panelShadow = adaptiveColor(
        light: color(white: 0.0, alpha: 0.10),
        dark: color(white: 0.0, alpha: 0.22)
    )
    static let controlShadow = adaptiveColor(
        light: color(white: 0.0, alpha: 0.08),
        dark: color(white: 0.0, alpha: 0.18)
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

enum TimerTomatoCardVariant {
    case hero
    case panel
    case row

    var cornerRadius: CGFloat {
        switch self {
        case .hero:
            TimerTomatoDesign.heroCornerRadius
        case .panel:
            TimerTomatoDesign.panelCornerRadius
        case .row:
            TimerTomatoDesign.rowCornerRadius
        }
    }

    var shadowColor: Color {
        switch self {
        case .hero:
            TimerTomatoDesign.heroShadow
        case .panel:
            TimerTomatoDesign.panelShadow
        case .row:
            .clear
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .hero:
            28
        case .panel:
            16
        case .row:
            0
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .hero:
            18
        case .panel:
            10
        case .row:
            0
        }
    }

    var hasExplicitBorder: Bool {
        switch self {
        case .hero, .panel:
            true
        case .row:
            false
        }
    }
}

private struct TimerTomatoCardModifier: ViewModifier {
    let variant: TimerTomatoCardVariant
    let isInteractive: Bool

    private var cornerRadius: CGFloat {
        variant.cornerRadius
    }

    func body(content: Content) -> some View {
        card(content: content)
    }

    @ViewBuilder
    private func card(content: Content) -> some View {
        if isInteractive {
            baseCard(content: content)
                .glassEffect(
                    .regular.interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
                .shadow(color: variant.shadowColor, radius: variant.shadowRadius, x: 0, y: variant.shadowY)
                .overlay {
                    cardBorder
                }
        } else {
            baseCard(content: content)
                .glassEffect(
                    .regular,
                    in: .rect(cornerRadius: cornerRadius)
                )
                .shadow(color: variant.shadowColor, radius: variant.shadowRadius, x: 0, y: variant.shadowY)
                .overlay {
                    cardBorder
                }
        }
    }

    private func baseCard(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(TimerTomatoDesign.surfaceFill)
            }
    }

    @ViewBuilder
    private var cardBorder: some View {
        if variant.hasExplicitBorder {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(TimerTomatoDesign.cardBorder, lineWidth: TimerTomatoDesign.cardBorderWidth)
                .allowsHitTesting(false)
        }
    }
}

extension View {
    func timerTomatoCard(_ variant: TimerTomatoCardVariant, isInteractive: Bool = false) -> some View {
        modifier(TimerTomatoCardModifier(variant: variant, isInteractive: isInteractive))
    }

    func timerTomatoHitTarget(
        minWidth: CGFloat = TimerTomatoDesign.minimumHitTarget,
        minHeight: CGFloat = TimerTomatoDesign.minimumHitTarget
    ) -> some View {
        frame(minWidth: minWidth, minHeight: minHeight)
            .contentShape(Rectangle())
    }
}
