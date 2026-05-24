//
//  SessionListView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct SessionListView: View {
    let sessions: [PomodoroSession]

    private var visibleSessions: [PomodoroSession] {
        Array(sessions.reversed().prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Heute", systemImage: "calendar")
                .font(.callout)
                .bold()
                .foregroundStyle(.secondary)
                .imageScale(.small)
                .padding(.horizontal, 4)

            if sessions.isEmpty {
                SessionEmptyStateView()
            } else {
                VStack(spacing: 8) {
                    ForEach(visibleSessions) { session in
                        SessionRowView(session: session)
                    }
                }
            }
        }
    }
}
