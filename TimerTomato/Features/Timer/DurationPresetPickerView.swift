//
//  DurationPresetPickerView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct DurationPresetPickerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var pulsedPreset: Int?

    @Bindable var store: PomodoroStore

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : .snappy(duration: 0.22)
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(PomodoroStore.durationPresets, id: \.self) { minutes in
                presetButton(minutes: minutes)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .backgroundPreferenceValue(DurationPresetBoundsKey.self) { bounds in
            GeometryReader { proxy in
                if let anchor = bounds[store.selectedMinutes] {
                    let frame = proxy[anchor]

                    Capsule()
                        .fill(TimerTomatoDesign.mint.opacity(0.12))
                        .overlay {
                            Capsule()
                                .strokeBorder(TimerTomatoDesign.mint.opacity(0.34), lineWidth: 0.8)
                        }
                        .frame(width: frame.width, height: frame.height)
                        .position(x: frame.midX, y: frame.midY)
                        .allowsHitTesting(false)
                        .animation(selectionAnimation, value: store.selectedMinutes)
                }
            }
        }
        .onChange(of: store.selectedMinutes) { _, newValue in
            pulseSelectedPreset(newValue)
        }
    }

    private func presetButton(minutes: Int) -> some View {
        let isSelected = store.selectedMinutes == minutes

        return Button {
            store.selectPreset(minutes: minutes)
        } label: {
            Text(PomodoroFormatters.minutesText(minutes))
                .font(.footnote.monospacedDigit())
                .bold(isSelected)
                .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                .scaleEffect(pulsedPreset == minutes ? 1.10 : 1)
                .frame(minWidth: 50, minHeight: TimerTomatoDesign.compactHitTarget)
                .padding(.horizontal, 5)
                .padding(.vertical, 6)
                .contentShape(Capsule())
        }
        .timerTomatoHitTarget(minWidth: 54, minHeight: TimerTomatoDesign.compactHitTarget)
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) Minuten")
        .accessibilityValue(isSelected ? "Ausgewählt" : "")
        .anchorPreference(key: DurationPresetBoundsKey.self, value: .bounds) { anchor in
            [minutes: anchor]
        }
    }

    private func pulseSelectedPreset(_ minutes: Int) {
        guard !reduceMotion else {
            pulsedPreset = nil
            return
        }

        withAnimation(.bouncy(duration: 0.24, extraBounce: 0.20)) {
            pulsedPreset = minutes
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 160_000_000)
            guard pulsedPreset == minutes else { return }

            withAnimation(.bouncy(duration: 0.24, extraBounce: 0.08)) {
                pulsedPreset = nil
            }
        }
    }
}

private struct DurationPresetBoundsKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [Int: Anchor<CGRect>],
        nextValue: () -> [Int: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { _, next in next }
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
