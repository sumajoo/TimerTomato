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
        HStack(spacing: 5) {
            ForEach(PomodoroStore.durationPresets, id: \.self) { minutes in
                presetButton(minutes: minutes)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .contain)
    }

    private func presetButton(minutes: Int) -> some View {
        let isSelected = store.selectedMinutes == minutes

        return Button {
            store.selectDurationPreset(minutes: minutes)
        } label: {
            Text(PomodoroFormatters.minutesText(minutes))
                .font(.caption.monospacedDigit())
                .bold(isSelected)
                .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                .frame(minWidth: 44, minHeight: TimerTomatoDesign.compactHitTarget)
                .padding(.horizontal, 3)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(TimerTomatoDesign.mint.opacity(0.12))
                            .overlay {
                                Capsule()
                                    .strokeBorder(TimerTomatoDesign.mint.opacity(0.30), lineWidth: 0.8)
                            }
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) Minuten")
        .accessibilityValue(isSelected ? "Ausgewählt" : "")
    }
}

#if DEBUG
#Preview("Fokusdauer Presets") {
    DurationPresetPickerView(
        store: TimerTomatoPreviewData.store()
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
