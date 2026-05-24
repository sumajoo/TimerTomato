//
//  HistoryEmptyStateView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryEmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.title3)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Text("Noch kein Fokus an diesem Tag")
                .font(.footnote)
                .bold()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.rowCornerRadius)
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: TimerTomatoDesign.rowCornerRadius)
        )
    }
}

#if DEBUG
#Preview("Verlauf leer") {
    HistoryEmptyStateView()
        .padding()
        .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
