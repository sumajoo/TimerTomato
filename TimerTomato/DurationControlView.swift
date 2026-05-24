//
//  DurationControlView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct DurationControlView: View {
    @Bindable var store: PomodoroStore

    private var showsDetailText: Bool {
        store.status != .idle
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Fokusdauer")
                    .font(.subheadline)
                    .bold()

                if showsDetailText {
                    Text("Ab nächster Sitzung")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            .layoutPriority(1)

            Spacer()

            HStack(spacing: 4) {
                Button("Kürzer", systemImage: "minus", action: store.decreaseSelectedMinutes)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .contentShape(Circle())
                    .disabled(store.selectedMinutes <= PomodoroStore.minimumMinutes)
                    .help("Fokusdauer verkürzen")

                Text(PomodoroFormatters.minutesText(store.selectedMinutes))
                    .font(.headline.monospacedDigit())
                    .frame(minWidth: 58)

                Button("Länger", systemImage: "plus", action: store.increaseSelectedMinutes)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .contentShape(Circle())
                    .disabled(store.selectedMinutes >= PomodoroStore.maximumMinutes)
                    .help("Fokusdauer verlängern")
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .glassEffect(
                .regular,
                in: .capsule
            )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}
