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
    private let scrollBottomInset: CGFloat = 34
    private let scrollFadeHeight: CGFloat = 18

    private var sessions: [PomodoroSession] {
        store.sessions
    }

    private var orderedSessions: [PomodoroSession] {
        Array(sessions.reversed())
    }

    private var scrollFadeMask: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.black)

            LinearGradient(
                colors: [.black, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: scrollFadeHeight)
        }
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
                TodayStatsView(store: store)

                GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
                    SessionEmptyStateView()
                }
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 12) {
                        TodayStatsView(store: store)

                        GlassEffectContainer(spacing: 12) {
                            VStack(spacing: 12) {
                                ForEach(orderedSessions) { session in
                                    SessionRowView(session: session)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .contentMargins(.bottom, scrollBottomInset, for: .scrollContent)
                .scrollIndicators(.hidden)
                .frame(height: todayContentMaxHeight)
                .mask {
                    scrollFadeMask
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
