//
//  HistoryWeekCalendarView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryWeekCalendarView: View {
    @Binding var selectedDate: Date

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
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(days) { day in
                HistoryDayCellView(
                    day: day,
                    isSelected: store.isSameDay(day.date, selectedDate)
                ) {
                    selectedDate = day.date
                }
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.panelCornerRadius)
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: TimerTomatoDesign.panelCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: TimerTomatoDesign.panelCornerRadius)
                .strokeBorder(TimerTomatoDesign.surfaceMidline, lineWidth: 0.65)
        }
    }
}
