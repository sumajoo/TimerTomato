//
//  FocusHeatViews.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import SwiftUI

struct FocusHeatBackground: View {
    let intensity: Double

    private var clampedIntensity: Double {
        min(max(intensity, 0), 1)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: TimerTomatoDesign.heroCornerRadius, style: .continuous)
            .fill(TimerTomatoDesign.tomato.opacity(0.05 * clampedIntensity))
            .allowsHitTesting(false)
    }
}

struct FocusHeatBorder: View {
    let intensity: Double

    private var clampedIntensity: Double {
        min(max(intensity, 0), 1)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: TimerTomatoDesign.heroCornerRadius, style: .continuous)
            .stroke(TimerTomatoDesign.tomato.opacity(0.22 * clampedIntensity), lineWidth: TimerTomatoDesign.cardBorderWidth)
            .shadow(color: TimerTomatoDesign.tomato.opacity(0.16 * clampedIntensity), radius: 10, x: 0, y: 0)
            .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview("Focus Heat") {
    ZStack {
        FocusHeatBackground(intensity: 0.85)
        FocusHeatBorder(intensity: 0.85)
    }
    .frame(width: TimerTomatoDesign.contentWidth, height: 160)
    .padding()
}
#endif
