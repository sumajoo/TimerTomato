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
                .font(.title3)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Text("Noch keine Sitzungen")
                .font(.subheadline)
                .bold()

            Text("Starte deinen ersten Pomodoro.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .glassEffect(
            .regular.tint(TimerTomatoDesign.neutralTint),
            in: .rect(cornerRadius: TimerTomatoDesign.controlCornerRadius)
        )
        .accessibilityElement(children: .combine)
    }
}
