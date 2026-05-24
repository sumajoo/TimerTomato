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

    private var focusWinCount: Int {
        sessions.filter(\.isFocusWin).count
    }

    private var summaryText: String {
        PomodoroFormatters.focusWinsSummaryText(
            focusWins: focusWinCount,
            sessions: sessions.count,
            focusMinutes: focusMinutes,
            averagePauseSeconds: nil
        )
    }

    private var focusWinUnitText: String {
        focusWinCount == 1 ? "Fokus-Sieg" : "Fokus-Siege"
    }

    private var minuteUnitText: String {
        focusMinutes == 1 ? "Minute Fokus" : "Minuten Fokus"
    }

    private var goalText: String {
        if focusWinCount >= store.dailyGoalSessions {
            return "Tagesziel erreicht"
        }

        let remainingWins = store.dailyGoalSessions - focusWinCount
        let unit = remainingWins == 1 ? "Fokus-Sieg" : "Fokus-Siege"
        return "Noch \(remainingWins) \(unit) bis zum Ziel"
    }

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.dayTitle(for: selectedDate))
                            .font(.callout)
                            .bold()

                        Text(sessions.isEmpty ? "Keine Sitzungen" : summaryText)
                            .font(.footnote)
                            .foregroundStyle(TimerTomatoDesign.secondaryText)
                    }

                    Spacer()

                    Text("\(min(focusWinCount, store.dailyGoalSessions))/\(store.dailyGoalSessions)")
                        .font(.footnote.monospacedDigit())
                        .bold()
                        .foregroundStyle(focusWinCount >= store.dailyGoalSessions ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                }

                if sessions.isEmpty {
                    HistoryEmptyStateView()
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline, spacing: 18) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(focusWinCount)")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .monospacedDigit()
                                    .bold()

                                Text(focusWinUnitText)
                                    .font(.footnote)
                                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                            }

                            Divider()
                                .frame(height: 42)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(focusMinutes)")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .monospacedDigit()
                                    .bold()

                                Text(minuteUnitText)
                                    .font(.footnote)
                                    .foregroundStyle(TimerTomatoDesign.secondaryText)
                            }
                        }

                        Label(
                            goalText,
                            systemImage: focusWinCount >= store.dailyGoalSessions ? "checkmark.circle.fill" : "target"
                        )
                            .font(.footnote)
                            .foregroundStyle(focusWinCount >= store.dailyGoalSessions ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .timerTomatoCard(.panel)
        }
    }
}

#if DEBUG
#Preview("Tagesdetails") {
    HistoryDayDetailView(
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions),
        selectedDate: TimerTomatoPreviewData.referenceDate
    )
    .padding()
    .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
