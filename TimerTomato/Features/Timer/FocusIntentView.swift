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

    private var normalizedIntent: String? {
        PomodoroSession.normalizedIntent(store.pendingFocusIntent)
    }

    private var isCustomIntentActive: Bool {
        guard let normalizedIntent else {
            return isIntentFieldFocused
        }

        return isIntentFieldFocused || !PomodoroStore.focusIntentSuggestions.contains(normalizedIntent)
    }

    var body: some View {
        VStack(spacing: 5) {
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

            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.caption)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .accessibilityHidden(true)

                TextField("Eigenes Ziel", text: $store.pendingFocusIntent)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .lineLimit(1)
                    .focused($isIntentFieldFocused)

                if normalizedIntent != nil {
                    Button("Ziel leeren", systemImage: "xmark.circle.fill", action: store.clearFocusIntent)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .foregroundStyle(TimerTomatoDesign.tertiaryText)
                        .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                        .help("Fokus-Ziel leeren")
                }
            }
            .padding(.horizontal, 10)
            .frame(height: TimerTomatoDesign.compactHitTarget)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
            }
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .accessibilityElement(children: .contain)
    }

    private func intentChip(_ suggestion: String) -> some View {
        let isSelected = normalizedIntent == suggestion

        return Button(suggestion) {
            store.selectFocusIntentSuggestion(suggestion)
            isIntentFieldFocused = false
        }
        .font(.caption2)
        .fontWeight(isSelected ? .semibold : .medium)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
        .frame(height: 24)
        .padding(.horizontal, 10)
        .background { intentChipBackground(isActive: isSelected) }
        .timerTomatoHitTarget(minWidth: 64, minHeight: chipLayoutHeight)
        .buttonStyle(.plain)
        .help("Fokus-Ziel \(suggestion)")
    }

    private var customIntentChip: some View {
        Button("Eigenes Ziel", systemImage: "square.and.pencil") {
            isIntentFieldFocused = true
        }
        .font(.caption2)
        .fontWeight(isCustomIntentActive ? .semibold : .medium)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .labelStyle(.titleAndIcon)
        .foregroundStyle(isCustomIntentActive ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
        .frame(height: 24)
        .padding(.horizontal, 10)
        .background { intentChipBackground(isActive: isCustomIntentActive) }
        .timerTomatoHitTarget(minWidth: 108, minHeight: chipLayoutHeight)
        .buttonStyle(.plain)
        .help("Eigenes Fokus-Ziel eingeben")
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
