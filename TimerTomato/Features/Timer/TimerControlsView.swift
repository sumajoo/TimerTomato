//
//  TimerControlsView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct TimerControlsView: View {
    @Namespace private var glassNamespace

    let store: PomodoroStore

    private let primaryButtonHeight: CGFloat = 52
    private let secondaryButtonWidth: CGFloat = 72

    private var accentColor: Color {
        store.activeTimerKind == .breakTime ? TimerTomatoDesign.mint : TimerTomatoDesign.tomato
    }

    private var primaryButtonWidth: CGFloat {
        store.status == .idle && store.canStartBreak ? 188 : store.status == .idle ? 214 : 184
    }

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Spacer(minLength: 0)

                switch store.status {
                case .idle:
                    TimerControlPrimaryButton(
                        title: "Fokus starten",
                        systemImage: "play.fill",
                        tint: TimerTomatoDesign.tomato,
                        width: primaryButtonWidth,
                        height: primaryButtonHeight,
                        action: store.start
                    )
                        .disabled(!store.canStartFocus)
                        .glassEffectID("timer-primary-control", in: glassNamespace)
                        .glassEffectTransition(.matchedGeometry)

                    if store.canStartBreak {
                        TimerControlIconButton(
                            title: "Pause starten",
                            systemImage: "cup.and.saucer.fill",
                            tint: TimerTomatoDesign.mint,
                            width: secondaryButtonWidth,
                            height: primaryButtonHeight,
                            action: store.startBreak
                        )
                            .help("5 Minuten Pause starten")
                            .glassEffectID("timer-secondary-control", in: glassNamespace)
                            .glassEffectTransition(.matchedGeometry)
                    }
                case .running:
                    TimerControlPrimaryButton(
                        title: "Pause",
                        systemImage: "pause.fill",
                        tint: accentColor,
                        width: primaryButtonWidth,
                        height: primaryButtonHeight,
                        action: store.pause
                    )
                        .glassEffectID("timer-primary-control", in: glassNamespace)
                        .glassEffectTransition(.matchedGeometry)
                case .paused:
                    TimerControlPrimaryButton(
                        title: "Fortsetzen",
                        systemImage: "play.fill",
                        tint: accentColor,
                        width: primaryButtonWidth,
                        height: primaryButtonHeight,
                        action: store.resume
                    )
                        .glassEffectID("timer-primary-control", in: glassNamespace)
                        .glassEffectTransition(.matchedGeometry)
                }

                if store.status != .idle {
                    TimerControlIconButton(
                        title: "Zurücksetzen",
                        systemImage: "arrow.counterclockwise",
                        tint: TimerTomatoDesign.secondaryText,
                        width: secondaryButtonWidth,
                        height: primaryButtonHeight,
                        action: store.reset
                    )
                        .help("Zurücksetzen")
                        .glassEffectID("timer-secondary-control", in: glassNamespace)
                        .glassEffectTransition(.matchedGeometry)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

private struct TimerControlPrimaryButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .labelStyle(.titleAndIcon)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(width: width, height: height)
                .contentShape(Capsule())
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(tint)
        .accessibilityLabel(title)
    }
}

private struct TimerControlIconButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 21, weight: .semibold))
                .frame(width: width, height: height)
                .contentShape(Capsule())
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(tint)
        .accessibilityLabel(title)
    }
}

#if DEBUG
#Preview("Timer Controls") {
    TimerControlsView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
