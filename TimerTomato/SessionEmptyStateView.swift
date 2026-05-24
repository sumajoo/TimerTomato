//
//  SessionEmptyStateView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct SessionEmptyStateView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.body)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Text("Noch keine Sitzungen heute")
                .font(.callout)
                .bold()

            Text("Starte deinen ersten Fokusblock.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.panelCornerRadius)
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: TimerTomatoDesign.panelCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.panelCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            TimerTomatoDesign.surfaceHighlight,
                            TimerTomatoDesign.surfaceMidline,
                            TimerTomatoDesign.surfaceLowlight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .shadow(color: TimerTomatoDesign.panelShadow, radius: 16, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }
}
