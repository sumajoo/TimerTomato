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
        .timerTomatoCard(.panel)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Heute leer") {
    SessionEmptyStateView()
        .padding()
        .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
