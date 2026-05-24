//
//  TimerProgressBarView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerProgressBarView: View {
    let progress: Double

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)

                if clampedProgress > 0 {
                    Capsule()
                        .fill(TimerTomatoDesign.tomato)
                        .frame(width: proxy.size.width * clampedProgress)
                }
            }
        }
        .frame(height: 8)
        .accessibilityLabel("Fortschritt")
        .accessibilityValue("\(Int((clampedProgress * 100).rounded())) Prozent")
    }
}
