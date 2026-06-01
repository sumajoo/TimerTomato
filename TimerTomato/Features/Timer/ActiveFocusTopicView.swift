//
//  ActiveFocusTopicView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 31.05.26.
//

import SwiftUI

struct ActiveFocusTopicView: View {
    @FocusState private var isTopicFieldFocused: Bool

    @State private var isEditing = false
    @State private var customTopic = ""

    @Bindable var store: PomodoroStore

    private var firstTopicRow: [String] {
        Array(PomodoroStore.focusIntentSuggestions.prefix(3))
    }

    private var secondTopicRow: [String] {
        Array(PomodoroStore.focusIntentSuggestions.suffix(1))
    }

    var body: some View {
        Group {
            if isEditing {
                editor
            } else {
                collapsedButton
            }
        }
        .animation(.easeInOut(duration: 0.16), value: isEditing)
    }

    private var collapsedButton: some View {
        Button(action: openEditor) {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .accessibilityHidden(true)

                Text("Jetzt: \(store.activeFocusTopicText)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Image(systemName: "square.and.pencil")
                    .font(.caption2)
                    .accessibilityHidden(true)
            }
            .font(.caption)
            .foregroundStyle(TimerTomatoDesign.mint)
            .padding(.horizontal, 9)
            .frame(height: 26)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
                    .overlay {
                        Capsule()
                            .strokeBorder(TimerTomatoDesign.mint.opacity(0.20), lineWidth: 0.7)
                    }
            }
        }
        .buttonStyle(.plain)
        .timerTomatoHitTarget(minHeight: TimerTomatoDesign.compactHitTarget)
        .help("Fokus-Thema ändern")
    }

    private var editor: some View {
        VStack(spacing: 4) {
            VStack(spacing: 1) {
                HStack(spacing: 4) {
                    ForEach(firstTopicRow, id: \.self) { suggestion in
                        topicChip(suggestion)
                    }
                }

                HStack(spacing: 4) {
                    ForEach(secondTopicRow, id: \.self) { suggestion in
                        topicChip(suggestion)
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.caption2)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .accessibilityHidden(true)

                TextField("Eigenes Thema", text: $customTopic)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .lineLimit(1)
                    .focused($isTopicFieldFocused)
                    .onSubmit(applyCustomTopic)

                Button("Thema übernehmen", systemImage: "checkmark") {
                    applyCustomTopic()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(TimerTomatoDesign.mint)
                .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                .help("Thema übernehmen")

                Button("Abbrechen", systemImage: "xmark") {
                    closeEditor()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(TimerTomatoDesign.tertiaryText)
                .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                .help("Abbrechen")
            }
            .padding(.horizontal, 8)
            .frame(height: TimerTomatoDesign.compactHitTarget)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.surfaceFill)
                    .overlay {
                        Capsule()
                            .strokeBorder(TimerTomatoDesign.mint.opacity(0.16), lineWidth: 0.7)
                    }
            }
        }
        .onExitCommand(perform: closeEditor)
    }

    private func topicChip(_ suggestion: String) -> some View {
        let isSelected = store.activeFocusIntentText == suggestion

        return Button(suggestion) {
            applyTopic(suggestion)
        }
        .font(.caption2)
        .fontWeight(isSelected ? .semibold : .medium)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .foregroundStyle(isSelected ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
        .frame(height: 24)
        .padding(.horizontal, 10)
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    Capsule()
                        .strokeBorder(TimerTomatoDesign.mint.opacity(isSelected ? 0.42 : 0.16), lineWidth: isSelected ? 0.9 : 0.7)
                }
        }
        .timerTomatoHitTarget(minWidth: 64, minHeight: 26)
        .buttonStyle(.plain)
        .help("Zu \(suggestion) wechseln")
    }

    private func openEditor() {
        customTopic = store.activeFocusIntentText ?? ""
        isEditing = true
        isTopicFieldFocused = true
    }

    private func closeEditor() {
        isEditing = false
        customTopic = ""
        isTopicFieldFocused = false
    }

    private func applyCustomTopic() {
        applyTopic(customTopic)
    }

    private func applyTopic(_ topic: String?) {
        store.changeActiveFocusIntent(topic)
        closeEditor()
    }
}

#if DEBUG
#Preview("Aktives Fokus-Thema") {
    ActiveFocusTopicView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
