//
//  HistoryScreenView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryScreenView: View {
    @Binding var selectedDate: Date

    @Bindable var store: PomodoroStore

    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HistoryHeaderView(
                selectedDate: $selectedDate,
                store: store,
                onBack: onBack
            )

            HistoryWeekCalendarView(
                selectedDate: $selectedDate,
                store: store
            )

            HistoryDayDetailView(
                store: store,
                selectedDate: selectedDate
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
