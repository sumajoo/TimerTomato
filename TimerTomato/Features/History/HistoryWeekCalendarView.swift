//
//  HistoryWeekCalendarView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryWeekCalendarView: View {
    @Binding var selectedDate: Date

    @Namespace private var glassNamespace

    let store: PomodoroStore

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: 0), spacing: 4),
            count: 7
        )
    }

    private var days: [PomodoroHistoryDay] {
        store.historyDays(containing: selectedDate)
    }

    var body: some View {
        GlassEffectContainer(spacing: 4) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(days) { day in
                    HistoryDayCellView(
                        day: day,
                        isSelected: store.isSameDay(day.date, selectedDate),
                        glassNamespace: glassNamespace
                    ) {
                        selectedDate = day.date
                    }
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity)
            .timerTomatoCard(.panel)
        }
    }
}

#if DEBUG
#Preview("Wochenübersicht") {
    HistoryWeekCalendarView(
        selectedDate: .constant(TimerTomatoPreviewData.referenceDate),
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions)
    )
    .padding()
    .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
