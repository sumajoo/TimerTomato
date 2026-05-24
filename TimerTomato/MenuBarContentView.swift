//
//  MenuBarContentView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct MenuBarContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Bindable var store: PomodoroStore

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(spacing: TimerTomatoDesign.panelSpacing) {
                MenuBarHeaderView(store: store)
                TimerStatusView(store: store)
                DurationControlView(store: store)
                SessionListView(sessions: store.sessions)
            }
            .padding(16)
        }
        .frame(width: TimerTomatoDesign.contentWidth)
        .background {
            LinearGradient(
                colors: [
                    TimerTomatoDesign.backgroundTop,
                    TimerTomatoDesign.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .onAppear(perform: store.refreshForToday)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: store.status)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: store.sessionsCompletedToday)
    }
}

#Preview {
    MenuBarContentView(
        store: PomodoroStore(
            defaults: .standard,
            persistenceKey: "TimerTomato.Preview",
            notifier: UserNotificationScheduler(),
            shouldScheduleTimer: false
        )
    )
}
