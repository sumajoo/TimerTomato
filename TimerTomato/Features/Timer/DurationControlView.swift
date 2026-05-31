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
        GlassEffectContainer(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Fokusdauer")
                            .font(.subheadline)
                            .bold()

                        if showsDetailText {
                            Text("Ab nächster Session")
                                .font(.footnote)
                                .foregroundStyle(TimerTomatoDesign.tertiaryText)
                        }
                    }
                    .layoutPriority(1)

                    Spacer()

                    HStack(spacing: 0) {
                        StepperIconButton(
                            title: "Fokusdauer verkürzen",
                            systemImage: "minus",
                            isDisabled: store.selectedMinutes <= PomodoroStore.minimumMinutes,
                            action: store.decreaseSelectedMinutes
                        )

                        Text(PomodoroFormatters.minutesText(store.selectedMinutes))
                            .font(.headline.monospacedDigit())
                            .frame(minWidth: 62)

                        StepperIconButton(
                            title: "Fokusdauer verlängern",
                            systemImage: "plus",
                            isDisabled: store.selectedMinutes >= PomodoroStore.maximumMinutes,
                            action: store.increaseSelectedMinutes
                        )
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(TimerTomatoDesign.surfaceFill)
                    }
                    .glassEffect(
                        .regular.interactive(),
                        in: .capsule
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        TimerTomatoDesign.surfaceHighlight,
                                        TimerTomatoDesign.surfaceMidline,
                                        TimerTomatoDesign.surfaceLowlight
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.75
                            )
                    }
                    .shadow(color: TimerTomatoDesign.controlShadow, radius: 12, x: 0, y: 7)
                }

                DurationPresetPickerView(store: store)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
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
