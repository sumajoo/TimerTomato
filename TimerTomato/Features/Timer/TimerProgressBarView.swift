//
//  TimerProgressBarView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerProgressBarView: View {
    let progress: Double
    let tint: Color
    let heatIntensity: Double

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var clampedHeatIntensity: Double {
        min(max(heatIntensity, 0), 1)
    }

    init(progress: Double, tint: Color = TimerTomatoDesign.tomato, heatIntensity: Double = 0) {
        self.progress = progress
        self.tint = tint
        self.heatIntensity = heatIntensity
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TimerTomatoDesign.trackFill)

                if clampedProgress > 0 {
                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * clampedProgress)
                        .overlay {
                            Capsule()
                                .fill(Color.white.opacity(0.08 * clampedHeatIntensity))
                        }
                        .shadow(color: tint.opacity(0.18 * clampedHeatIntensity), radius: 5, x: 0, y: 0)
                }
            }
        }
        .frame(height: 9)
        .accessibilityLabel("Fortschritt")
        .accessibilityValue("\(Int((clampedProgress * 100).rounded())) Prozent")
    }
}

#if DEBUG
#Preview("Fortschritt") {
    TimerProgressBarView(progress: 0.62)
        .padding()
        .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
