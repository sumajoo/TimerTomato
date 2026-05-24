//
//  DurationControlView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct DurationControlView: View {
    @Bindable var store: PomodoroStore

    private var detailText: String {
        if store.status == .idle {
            return "Dauer der nächsten Sitzung"
        }

        return "Gilt ab der nächsten Sitzung"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Fokusdauer")
                    .font(.subheadline)
                    .bold()

                Text(detailText)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button("Kürzer", systemImage: "minus", action: store.decreaseSelectedMinutes)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .disabled(store.selectedMinutes <= PomodoroStore.minimumMinutes)
                    .help("Fokusdauer verkürzen")

                Text(PomodoroFormatters.minutesText(store.selectedMinutes))
                    .font(.headline.monospacedDigit())
                    .frame(minWidth: 54)

                Button("Länger", systemImage: "plus", action: store.increaseSelectedMinutes)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .disabled(store.selectedMinutes >= PomodoroStore.maximumMinutes)
                    .help("Fokusdauer verlängern")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .tint(TimerTomatoDesign.tomato)
        .glassEffect(
            .regular.tint(TimerTomatoDesign.surfaceTint),
            in: .rect(cornerRadius: TimerTomatoDesign.controlCornerRadius)
        )
        .accessibilityElement(children: .combine)
    }
}
