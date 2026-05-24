//
//  DurationPresetPickerView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct DurationPresetPickerView: View {
    @Bindable var store: PomodoroStore

    var body: some View {
        HStack(spacing: 4) {
            ForEach(PomodoroStore.durationPresets, id: \.self) { minutes in
                Button(PomodoroFormatters.minutesText(minutes)) {
                    store.selectPreset(minutes: minutes)
                }
                .font(.footnote.monospacedDigit())
                .bold(store.selectedMinutes == minutes)
                .foregroundStyle(store.selectedMinutes == minutes ? .primary : .secondary)
                .frame(minWidth: 50)
                .padding(.horizontal, 5)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(store.selectedMinutes == minutes ? TimerTomatoDesign.surfaceFill : .clear)
                }
                .glassEffect(
                    .regular,
                    in: .capsule
                )
                .buttonStyle(.plain)
                .accessibilityLabel("\(minutes) Minuten")
                .accessibilityValue(store.selectedMinutes == minutes ? "Ausgewählt" : "")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#if DEBUG
#Preview("Dauer Shortcuts") {
    DurationPresetPickerView(
        store: TimerTomatoPreviewData.store()
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
