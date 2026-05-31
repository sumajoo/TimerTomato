//
//  MenuBarContentView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct MenuBarContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var screen = MenuBarScreen.main
    @State private var selectedHistoryDate = Date()

    @Bindable var store: PomodoroStore

    private var contentWidth: CGFloat {
        switch screen {
        case .main:
            TimerTomatoDesign.contentWidth
        case .history:
            TimerTomatoDesign.historyContentWidth
        }
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            MenuBarHeaderView(store: store, showHistory: showHistory)

            TimerStatusView(store: store)
                .padding(.top, 14)

            DurationControlView(store: store)
                .padding(.top, 12)

            SessionListView(store: store)
                .padding(.top, 18)
        }
    }

    var body: some View {
        Group {
            switch screen {
            case .main:
                mainView
            case .history:
                HistoryScreenView(
                    selectedDate: $selectedHistoryDate,
                    store: store,
                    onBack: showMain
                )
            }
        }
        .frame(width: contentWidth)
        .padding(TimerTomatoDesign.contentPadding)
        .onAppear {
            store.refreshLifecycleState()
            store.refreshNotificationPermission()
        }
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: store.status)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: store.sessionsCompletedToday)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: store.focusWinsToday)
        .animation(reduceMotion ? nil : .snappy(duration: 0.22), value: screen)
    }

    private func showHistory() {
        selectedHistoryDate = store.currentDate
        screen = .history
    }

    private func showMain() {
        screen = .main
    }
}

#if DEBUG
#Preview("Menübar") {
    MenuBarContentView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
}
#endif
