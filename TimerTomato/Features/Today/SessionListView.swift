//
//  SessionListView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct SessionListView: View {
    let store: PomodoroStore

    private let todayContentMaxHeight: CGFloat = 166

    private var sessions: [PomodoroSession] {
        store.sessions
    }

    private var orderedSessions: [PomodoroSession] {
        Array(sessions.reversed())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Heute", systemImage: "calendar")
                .font(.callout)
                .bold()
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .imageScale(.small)
                .padding(.horizontal, 4)

            if sessions.isEmpty {
                GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
                    TodayStatsView(store: store)
                    SessionEmptyStateView()
                }
            } else {
                ScrollView(.vertical) {
                    GlassEffectContainer(spacing: 12) {
                        TodayStatsView(store: store)

                        VStack(spacing: 12) {
                            ForEach(orderedSessions) { session in
                                SessionRowView(session: session)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 6)
                }
                .scrollIndicators(.automatic)
                .frame(height: todayContentMaxHeight)
            }
        }
    }
}

#if DEBUG
#Preview("Heute Liste") {
    SessionListView(
        store: TimerTomatoPreviewData.store()
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
