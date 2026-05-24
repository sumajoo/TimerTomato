//
//  HistoryDayDetailView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryDayDetailView: View {
    let store: PomodoroStore
    let selectedDate: Date

    private var sessions: [PomodoroSession] {
        store.sessions(on: selectedDate)
    }

    private var focusMinutes: Int {
        sessions.reduce(0) { result, session in
            result + session.plannedMinutes
        }
    }

    private var summaryText: String {
        PomodoroFormatters.todaySummaryText(
            sessions: sessions.count,
            focusMinutes: focusMinutes,
            averagePauseSeconds: nil
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.dayTitle(for: selectedDate))
                        .font(.callout)
                        .bold()

                    Text(sessions.isEmpty ? "Keine Sitzungen" : summaryText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(min(sessions.count, store.dailyGoalSessions))/\(store.dailyGoalSessions)")
                    .font(.footnote.monospacedDigit())
                    .bold()
                    .foregroundStyle(sessions.count >= store.dailyGoalSessions ? TimerTomatoDesign.mint : .secondary)
            }

            if sessions.isEmpty {
                HistoryEmptyStateView()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(sessions.reversed()) { session in
                            HistorySessionRowView(session: session)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: 260)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
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
