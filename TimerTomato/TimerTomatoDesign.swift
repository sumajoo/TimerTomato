//
//  TimerTomatoDesign.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

enum TimerTomatoDesign {
    static let heroCornerRadius: CGFloat = 26
    static let panelCornerRadius: CGFloat = 18
    static let rowCornerRadius: CGFloat = 14
    static let panelSpacing: CGFloat = 16
    static let contentWidth: CGFloat = 340
    static let historyContentWidth: CGFloat = contentWidth + 36
    static let contentPadding: CGFloat = 16

    static let tomato = Color(red: 0.82, green: 0.18, blue: 0.14)
    static let mint = Color(red: 0.12, green: 0.58, blue: 0.46)
    static let surfaceFill = Color.white.opacity(0.78)
    static let surfaceHighlight = Color.white.opacity(0.72)
    static let surfaceMidline = Color.white.opacity(0.22)
    static let surfaceLowlight = Color.black.opacity(0.08)
    static let heroShadow = Color.black.opacity(0.16)
    static let panelShadow = Color.black.opacity(0.10)
    static let controlShadow = Color.black.opacity(0.08)
}
