//
//  MenuBarContentView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct MenuBarContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.openWindow) private var openWindow

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

    private var showsIdleSupport: Bool {
        store.status == .idle && !store.hasPendingOutcome
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            MenuBarHeaderView(store: store, showHistory: showHistory)

            TimerStatusView(store: store)
                .padding(.top, 14)

            if showsIdleSupport {
                DurationControlView(store: store)
                    .padding(.top, 10)

                SessionListView(store: store)
                    .padding(.top, 14)
            }
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
            openChecklistWindowIfNeeded()
        }
        .onChange(of: store.focusChecklistWindowRequestID) { _, _ in
            openChecklistWindowIfNeeded()
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

    private func openChecklistWindowIfNeeded() {
        guard store.activeFocusChecklist != nil else {
            return
        }

        openWindow(id: FocusChecklistWindowView.windowID)
    }
}

#if DEBUG
#Preview("Menübar") {
    MenuBarContentView(
        store: TimerTomatoPreviewData.store(timerState: .focusRunning)
    )
}
#endif
