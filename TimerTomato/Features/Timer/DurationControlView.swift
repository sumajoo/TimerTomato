//
//  DurationControlView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct DurationControlView: View {
    @Bindable var store: PomodoroStore

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 10) {
                Text("Dauer")
                    .font(.caption.bold())
                    .foregroundStyle(TimerTomatoDesign.secondaryText)

                Spacer(minLength: 8)

                HStack(spacing: 0) {
                    StepperIconButton(
                        title: "Fokusdauer verkürzen",
                        systemImage: "minus",
                        isDisabled: store.selectedMinutes <= PomodoroStore.minimumMinutes,
                        action: store.decreaseSelectedMinutes
                    )

                    Text(PomodoroFormatters.minutesText(store.selectedMinutes))
                        .font(.subheadline.monospacedDigit())
                        .bold()
                        .frame(minWidth: 58)

                    StepperIconButton(
                        title: "Fokusdauer verlängern",
                        systemImage: "plus",
                        isDisabled: store.selectedMinutes >= PomodoroStore.maximumMinutes,
                        action: store.increaseSelectedMinutes
                    )
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .glassEffect(.regular.interactive(), in: .capsule)
            }

            DurationPresetPickerView(store: store)
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .contain)
    }
}

#if DEBUG
#Preview("Fokusdauer") {
    DurationControlView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
