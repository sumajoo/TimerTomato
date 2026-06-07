//
//  FocusIntentView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import SwiftUI

struct FocusIntentView: View {
    @FocusState private var isIntentFieldFocused: Bool

    @Bindable var store: PomodoroStore

    private let chipLayoutHeight: CGFloat = 24
    private let customChipMinimumWidth: CGFloat = 112
    private let customChipMaximumWidth: CGFloat = 218
    private let customChipTextHorizontalBuffer: CGFloat = 48

    private var normalizedIntent: String? {
        PomodoroSession.normalizedIntent(store.pendingFocusIntent)
    }

    private var isCustomIntentActive: Bool {
        guard let normalizedIntent else {
            return isIntentFieldFocused
        }

        return isIntentFieldFocused || !PomodoroStore.focusIntentSuggestions.contains(normalizedIntent)
    }

    private var customIntentText: String {
        guard
            let normalizedIntent,
            !PomodoroStore.focusIntentSuggestions.contains(normalizedIntent)
        else {
            return ""
        }

        return normalizedIntent
    }

    private var customIntentChipWidth: CGFloat {
        let measuredText = customIntentText.isEmpty ? "Eigenes Ziel" : customIntentText
        let estimatedTextWidth = CGFloat(measuredText.count) * 6.6
        let preferredWidth = estimatedTextWidth + customChipTextHorizontalBuffer

        return min(max(preferredWidth, customChipMinimumWidth), customChipMaximumWidth)
    }

    private var customIntentFieldWidth: CGFloat {
        max(56, customIntentChipWidth - customChipTextHorizontalBuffer)
    }

    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 4) {
                ForEach(Array(PomodoroStore.focusIntentSuggestions.prefix(3)), id: \.self) { suggestion in
                    intentChip(suggestion)
                }
            }

            HStack(spacing: 4) {
                ForEach(Array(PomodoroStore.focusIntentSuggestions.suffix(1)), id: \.self) { suggestion in
                    intentChip(suggestion)
                }

                customIntentChip
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func intentChip(_ suggestion: String) -> some View {
        let isSelected = normalizedIntent == suggestion && !isCustomIntentActive

        return Button {
            store.selectFocusIntentSuggestion(suggestion)
            isIntentFieldFocused = false
        } label: {
            Text(suggestion)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .medium)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                .padding(.horizontal, 10)
                .frame(minWidth: 64, minHeight: chipLayoutHeight)
                .background { intentChipBackground(isActive: isSelected) }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .help("Fokus-Ziel \(suggestion)")
    }

    private var customIntentChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "square.and.pencil")
                .font(.caption2)
                .foregroundStyle(isCustomIntentActive ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                .accessibilityHidden(true)

            TextField("Eigenes Ziel", text: customIntentBinding)
                .textFieldStyle(.plain)
                .font(.caption2.weight(isCustomIntentActive ? .semibold : .medium))
                .foregroundStyle(isCustomIntentActive ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                .lineLimit(1)
                .focused($isIntentFieldFocused)
                .frame(width: customIntentFieldWidth)
        }
        .padding(.horizontal, 10)
        .frame(width: customIntentChipWidth, height: 24)
        .background { intentChipBackground(isActive: isCustomIntentActive) }
        .timerTomatoHitTarget(minWidth: customChipMinimumWidth, minHeight: chipLayoutHeight)
        .contentShape(Capsule())
        .onTapGesture {
            if let normalizedIntent, PomodoroStore.focusIntentSuggestions.contains(normalizedIntent) {
                store.clearFocusIntent()
            }

            isIntentFieldFocused = true
        }
        .help("Eigenes Fokus-Ziel eingeben")
    }

    private var customIntentBinding: Binding<String> {
        Binding(
            get: {
                customIntentText
            },
            set: { text in
                store.pendingFocusIntent = text
            }
        )
    }

    private func intentChipBackground(isActive: Bool) -> some View {
        Capsule()
            .fill(TimerTomatoDesign.surfaceFill)
            .overlay {
                Capsule()
                    .strokeBorder(
                        TimerTomatoDesign.mint.opacity(isActive ? 0.42 : 0.16),
                        lineWidth: isActive ? 0.9 : 0.7
                    )
            }
    }
}

#if DEBUG
#Preview("Fokus-Intent") {
    FocusIntentView(
        store: TimerTomatoPreviewData.store(timerState: .idle)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
