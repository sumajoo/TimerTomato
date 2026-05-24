//
//  SessionListView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct SessionListView: View {
    let store: PomodoroStore

    private var sessions: [PomodoroSession] {
        store.sessions
    }

    private var visibleSessions: [PomodoroSession] {
        Array(sessions.reversed().prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Heute", systemImage: "calendar")
                .font(.callout)
                .bold()
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .imageScale(.small)
                .padding(.horizontal, 4)

            TodayStatsView(store: store)

            if sessions.isEmpty {
                GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
                    SessionEmptyStateView()
                }
            } else {
                GlassEffectContainer(spacing: 14) {
                    VStack(spacing: 14) {
                        ForEach(visibleSessions) { session in
                            SessionRowView(session: session)
                        }
                    }
                }
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
