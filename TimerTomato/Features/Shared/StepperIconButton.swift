//
//  StepperIconButton.swift
//  TimerTomato
//
//  Created by Jonas Becker on 26.05.26.
//

import SwiftUI

struct StepperIconButton: View {
    let title: String
    let systemImage: String
    let isDisabled: Bool
    let action: () -> Void

    private var foregroundStyle: Color {
        isDisabled ? TimerTomatoDesign.tertiaryText : TimerTomatoDesign.secondaryText
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .medium))
                .frame(width: TimerTomatoDesign.minimumHitTarget, height: TimerTomatoDesign.minimumHitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundStyle)
        .disabled(isDisabled)
        .help(title)
        .accessibilityLabel(title)
    }
}
