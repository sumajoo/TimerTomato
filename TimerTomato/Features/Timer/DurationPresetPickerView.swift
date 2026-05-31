//
//  DurationPresetPickerView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct DurationPresetPickerView: View {
    @Namespace private var glassNamespace

    @Bindable var store: PomodoroStore

    var body: some View {
        HStack(spacing: 4) {
            ForEach(PomodoroStore.durationPresets, id: \.self) { minutes in
                presetButton(minutes: minutes)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func presetButton(minutes: Int) -> some View {
        let isSelected = store.selectedMinutes == minutes

        if isSelected {
            basePresetButton(minutes: minutes, isSelected: isSelected)
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(
                    .regular.interactive(),
                    in: .capsule
                )
                .glassEffectID("duration-preset-selection", in: glassNamespace)
        } else {
            basePresetButton(minutes: minutes, isSelected: isSelected)
        }
    }

    private func basePresetButton(minutes: Int, isSelected: Bool) -> some View {
        Button(PomodoroFormatters.minutesText(minutes)) {
            store.selectPreset(minutes: minutes)
        }
        .font(.footnote.monospacedDigit())
        .bold(isSelected)
        .foregroundStyle(isSelected ? Color.primary : TimerTomatoDesign.secondaryText)
        .frame(minWidth: 50)
        .padding(.horizontal, 5)
        .padding(.vertical, 6)
        .timerTomatoHitTarget(minWidth: 54)
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) Minuten")
        .accessibilityValue(isSelected ? "Ausgewählt" : "")
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
