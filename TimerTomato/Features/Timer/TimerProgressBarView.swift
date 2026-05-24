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

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    init(progress: Double, tint: Color = TimerTomatoDesign.tomato) {
        self.progress = progress
        self.tint = tint
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.tertiary)

                if clampedProgress > 0 {
                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * clampedProgress)
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
