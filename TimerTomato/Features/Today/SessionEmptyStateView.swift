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
                .foregroundStyle(TimerTomatoDesign.tertiaryText)
                .accessibilityHidden(true)

            Text("Noch keine Sessions heute")
                .font(.callout)
                .bold()

            Text("Starte deinen ersten Fokusblock.")
                .font(.footnote)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
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
