//
//  TimerTomatoDesign.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

enum TimerTomatoDesign {
    static let panelCornerRadius: CGFloat = 20
    static let rowCornerRadius: CGFloat = 14
    static let controlCornerRadius: CGFloat = 14
    static let panelSpacing: CGFloat = 12
    static let contentWidth: CGFloat = 340

    static let tomato = Color(red: 0.82, green: 0.18, blue: 0.14)
    static let backgroundTop = Color(red: 0.94, green: 0.96, blue: 0.98)
    static let backgroundBottom = Color(red: 0.89, green: 0.93, blue: 0.95)
    static let surfaceTint = Color.white.opacity(0.12)
    static let neutralTint = Color.white.opacity(0.08)
    static let timerTint = tomato.opacity(0.12)
}
