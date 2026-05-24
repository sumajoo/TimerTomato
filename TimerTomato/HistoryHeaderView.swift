//
//  HistoryHeaderView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryHeaderView: View {
    @Binding var selectedDate: Date

    let store: PomodoroStore
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button("Zurück", systemImage: "chevron.left", action: onBack)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
                .buttonStyle(.plain)
                .help("Zurück")

            VStack(alignment: .leading, spacing: 1) {
                Text("Verlauf")
                    .font(.headline)
                    .bold()

                Text(store.weekTitle(containing: selectedDate))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Button("Vorherige Woche", systemImage: "chevron.left", action: previousWeek)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .frame(width: 30, height: 30)
                    .help("Vorherige Woche")

                Button("Nächste Woche", systemImage: "chevron.right", action: nextWeek)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .frame(width: 30, height: 30)
                    .help("Nächste Woche")
            }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
    }

    private func previousWeek() {
        selectedDate = store.dateByAddingWeeks(-1, to: selectedDate)
    }

    private func nextWeek() {
        selectedDate = store.dateByAddingWeeks(1, to: selectedDate)
    }
}
