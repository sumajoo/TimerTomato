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
    private let scrollTopInset: CGFloat = 14
    private let scrollBottomInset: CGFloat = 34
    private let scrollTopFadeHeight: CGFloat = 14
    private let scrollBottomFadeHeight: CGFloat = 18

    private var sessions: [PomodoroSession] {
        store.sessions
    }

    private var orderedSessions: [PomodoroSession] {
        Array(sessions.reversed())
    }

    private var hasReachedDailyGoal: Bool {
        store.dailyGoalProgress >= 1
    }

    private var todayGoalHeaderText: String {
        hasReachedDailyGoal ? "Tagesziel erreicht" : "Tagesziel \(store.dailyGoalCountText)"
    }

    private var todayGoalHeaderSystemImage: String {
        hasReachedDailyGoal ? "checkmark.circle.fill" : "target"
    }

    private var todayGoalHeaderTint: Color {
        hasReachedDailyGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText
    }

    private var todayHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Label("Heute", systemImage: "calendar")
                .font(.callout)
                .bold()
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .imageScale(.small)

            Spacer(minLength: 8)

            Label(todayGoalHeaderText, systemImage: todayGoalHeaderSystemImage)
                .font(.caption)
                .bold()
                .foregroundStyle(todayGoalHeaderTint)
                .imageScale(.small)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 4)
    }

    private var scrollFadeMask: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: scrollTopFadeHeight)

            Rectangle()
                .fill(.black)

            LinearGradient(
                colors: [.black, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: scrollBottomFadeHeight)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            todayHeader

            if sessions.isEmpty {
                GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
                    SessionEmptyStateView()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        GlassEffectContainer(spacing: 12) {
                            VStack(spacing: 12) {
                                ForEach(orderedSessions) { session in
                                    SessionRowView(session: session)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, scrollTopInset)
                    .padding(.bottom, scrollBottomInset)
                }
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
