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
            VStack(spacing: 0) {
                MenuBarHeaderView(store: store)

                TimerStatusView(store: store)
                    .padding(.top, 14)

                DurationControlView(store: store)
                    .padding(.top, 12)

                SessionListView(sessions: store.sessions)
                    .padding(.top, 18)
            }
            .padding(TimerTomatoDesign.contentPadding)
        }
        .frame(width: TimerTomatoDesign.contentWidth)
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
