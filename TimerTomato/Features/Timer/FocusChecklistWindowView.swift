//
//  FocusChecklistWindowView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 06.06.26.
//

import SwiftUI

struct FocusChecklistWindowView: View {
    static let windowID = "focus-checklist"

    @State private var isEditing = false

    @Bindable var store: PomodoroStore

    private var checklist: PomodoroChecklist? {
        store.activeFocusChecklist
    }

    private var titleText: String {
        if let goal = checklist?.goal, !goal.isEmpty {
            return "\(goal)-Checkliste"
        }

        return "Fokus-Checkliste"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let checklist {
                checklistContent(checklist)
            } else {
                inactiveState
            }
        }
        .padding(16)
        .padding(.trailing, checklist == nil ? 0 : TimerTomatoDesign.compactHitTarget)
        .frame(width: 320)
        .overlay(alignment: .topTrailing) {
            editModeControl
                .padding(16)
        }
        .navigationTitle(titleText)
        .onChange(of: checklist?.goal) {
            isEditing = false
        }
    }

    @ViewBuilder
    private var editModeControl: some View {
        if checklist != nil {
            Button(isEditing ? "Fertig" : "Bearbeiten", systemImage: isEditing ? "checkmark" : "pencil") {
                isEditing.toggle()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(isEditing ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
            .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
            .contentShape(Circle())
            .help(isEditing ? "Bearbeitung beenden" : "Checklist bearbeiten")
        }
    }

    private var inactiveState: some View {
        Text("Kein aktiver Fokus")
            .font(.callout)
            .foregroundStyle(TimerTomatoDesign.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
    }

    private func checklistContent(_ checklist: PomodoroChecklist) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if checklist.items.isEmpty {
                Text("Noch keine Schritte")
                    .font(.callout)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(checklist.items) { item in
                    checklistRow(item, goal: checklist.goal)
                }
            }

            if isEditing {
                Button("Schritt hinzufügen", systemImage: "plus") {
                    store.addChecklistItem(to: checklist.goal)
                }
                .font(.caption.bold())
                .labelStyle(.titleAndIcon)
                .foregroundStyle(TimerTomatoDesign.mint)
                .frame(maxWidth: .infinity, minHeight: TimerTomatoDesign.minimumHitTarget)
                .background {
                    Capsule()
                        .fill(TimerTomatoDesign.surfaceFill)
                        .overlay {
                            Capsule()
                                .strokeBorder(TimerTomatoDesign.mint.opacity(0.18), lineWidth: 0.7)
                        }
                }
                .buttonStyle(.plain)
                .disabled(checklist.items.count >= PomodoroChecklist.maximumItems)
                .help("Schritt hinzufügen")
            }
        }
    }

    private func checklistRow(_ item: PomodoroChecklistItem, goal: String) -> some View {
        HStack(spacing: 8) {
            Button {
                store.setChecklistItemCompleted(item.id, isCompleted: !item.isCompleted)
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isCompleted ? TimerTomatoDesign.mint : TimerTomatoDesign.tertiaryText)
                    .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
            }
            .buttonStyle(.plain)
            .help(item.isCompleted ? "Als offen markieren" : "Als erledigt markieren")

            if isEditing {
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Schritt", text: titleBinding(for: item, goal: goal))
                        .textFieldStyle(.plain)
                        .font(.callout)
                        .lineLimit(1)

                    Stepper(
                        PomodoroChecklistItem.reminderTimeText(for: item.reminderMinuteOffset),
                        value: reminderMinuteBinding(for: item, goal: goal),
                        in: 0...PomodoroChecklistItem.maximumReminderMinuteOffset,
                        step: 1
                    )
                    .font(.caption)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.callout)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(PomodoroChecklistItem.reminderTimeText(for: item.reminderMinuteOffset))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(TimerTomatoDesign.tertiaryText)
                }
            }

            if isEditing {
                Button("Löschen", systemImage: "trash") {
                    store.deleteChecklistItem(item.id, from: goal)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(TimerTomatoDesign.tertiaryText)
                .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                .help("Schritt löschen")
            }
        }
        .padding(.horizontal, 9)
        .frame(minHeight: TimerTomatoDesign.minimumHitTarget)
        .background {
            if isEditing {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TimerTomatoDesign.surfaceFill)
            }
        }
    }

    private func titleBinding(for item: PomodoroChecklistItem, goal: String) -> Binding<String> {
        Binding(
            get: {
                store.activeFocusChecklist?.items.first { $0.id == item.id }?.title ?? item.title
            },
            set: { title in
                store.updateChecklistItem(item.id, title: title, in: goal)
            }
        )
    }

    private func reminderMinuteBinding(for item: PomodoroChecklistItem, goal: String) -> Binding<Int> {
        Binding(
            get: {
                store.activeFocusChecklist?.items.first { $0.id == item.id }?.reminderMinuteOffset
                    ?? item.reminderMinuteOffset
            },
            set: { minuteOffset in
                store.updateChecklistItem(item.id, reminderMinuteOffset: minuteOffset, in: goal)
            }
        )
    }
}

#if DEBUG
#Preview("Fokus-Checklist") {
    FocusChecklistWindowView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
    .padding()
}
#endif
