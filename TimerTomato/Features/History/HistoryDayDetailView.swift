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

    private var sessionUnitText: String {
        sessions.count == 1 ? "Sitzung" : "Sitzungen"
    }

    private var minuteUnitText: String {
        focusMinutes == 1 ? "Minute Fokus" : "Minuten Fokus"
    }

    private var goalText: String {
        if sessions.count >= store.dailyGoalSessions {
            return "Tagesziel erreicht"
        }

        let remainingSessions = store.dailyGoalSessions - sessions.count
        let unit = remainingSessions == 1 ? "Sitzung" : "Sitzungen"
        return "Noch \(remainingSessions) \(unit) bis zum Ziel"
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
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline, spacing: 18) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(sessions.count)")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .monospacedDigit()
                                    .bold()

                                Text(sessionUnitText)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
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
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Label(
                            goalText,
                            systemImage: sessions.count >= store.dailyGoalSessions ? "checkmark.circle.fill" : "target"
                        )
                            .font(.footnote)
                            .foregroundStyle(sessions.count >= store.dailyGoalSessions ? TimerTomatoDesign.mint : .secondary)
                    }
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
