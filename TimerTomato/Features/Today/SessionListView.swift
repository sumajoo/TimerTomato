//
//  SessionListView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct SessionListView: View {
    let store: PomodoroStore
    let maxContentHeight: CGFloat?

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

            ScrollView(.vertical) {
                VStack(spacing: 14) {
                    TodayStatsView(store: store)

                    if sessions.isEmpty {
                        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
                            SessionEmptyStateView()
                        }
                    } else {
                        GlassEffectContainer(spacing: 14) {
                            VStack(spacing: 14) {
                                ForEach(orderedSessions) { session in
                                    SessionRowView(session: session)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom, 6)
            }
            .scrollIndicators(.automatic)
            .frame(maxHeight: maxContentHeight)
        }
    }
}

#if DEBUG
#Preview("Heute Liste") {
    SessionListView(
        store: TimerTomatoPreviewData.store(),
        maxContentHeight: 320
    )
    .padding()
    .frame(width: TimerTomatoDesign.contentWidth)
}
#endif
