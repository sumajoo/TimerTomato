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
        VStack(alignment: .leading, spacing: 14) {
            HistoryHeaderView(
                selectedDate: $selectedDate,
                store: store,
                onBack: onBack
            )

            HistoryWeekCalendarView(
                selectedDate: $selectedDate,
                store: store
            )

            HistoryWeekSummaryView(
                store: store,
                selectedDate: selectedDate
            )

            HistoryDayDetailView(
                store: store,
                selectedDate: selectedDate
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview("Verlauf") {
    HistoryScreenView(
        selectedDate: .constant(TimerTomatoPreviewData.referenceDate),
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions),
        onBack: {}
    )
    .padding()
    .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
