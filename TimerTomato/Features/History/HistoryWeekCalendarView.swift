//
//  HistoryWeekCalendarView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryWeekCalendarView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selectedDate: Date

    @State private var isExpanded = false

    @Namespace private var glassNamespace

    let store: PomodoroStore

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: 0), spacing: 4),
            count: 7
        )
    }

    private var days: [PomodoroHistoryDay] {
        if isExpanded {
            store.historyMonthDays(containing: selectedDate)
        } else {
            store.historyDays(containing: selectedDate)
        }
    }

    private var toggleLabel: String {
        isExpanded ? "Monatsübersicht einklappen" : "Monatsübersicht öffnen"
    }

    var body: some View {
        GlassEffectContainer(spacing: 4) {
            VStack(spacing: 5) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(days) { day in
                        HistoryDayCellView(
                            day: day,
                            isSelected: store.isSameDay(day.date, selectedDate),
                            isDimmed: isExpanded && !store.isSameMonth(day.date, selectedDate),
                            glassNamespace: glassNamespace
                        ) {
                            selectedDate = day.date
                        }
                    }
                }

                Image(systemName: "chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(TimerTomatoDesign.tertiaryText)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
            }
            .padding(.horizontal, 8)
            .padding(.top, 7)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .background {
                Button(action: toggleExpanded) {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(toggleLabel)
                .help(toggleLabel)
            }
            .timerTomatoCard(.panel, isInteractive: true)
        }
    }

    private func toggleExpanded() {
        if reduceMotion {
            isExpanded.toggle()
        } else {
            withAnimation(.snappy(duration: 0.22)) {
                isExpanded.toggle()
            }
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
