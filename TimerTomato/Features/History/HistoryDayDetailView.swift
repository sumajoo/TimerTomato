//
//  HistoryDayDetailView.swift
//  TimerTomato
//
//  Created by Jonas Becker on 24.05.26.
//

import SwiftUI

struct HistoryDayDetailView: View {
    @FocusState private var isSessionIntentFieldFocused: Bool

    @State private var editingSessionID: UUID?
    @State private var draftSessionIntent = ""

    let store: PomodoroStore
    let selectedDate: Date

    private var day: PomodoroHistoryDay {
        PomodoroHistoryDay(
            date: selectedDate,
            sessions: store.sessions(on: selectedDate),
            dailyGoalSessions: store.dailyGoalSessions
        )
    }

    private var dailyGoalSummaryText: String {
        let unit = store.dailyGoalSessions == 1 ? "Session" : "Sessions"
        return "Tagesziel: \(day.goalCountText) \(unit)"
    }

    private var dailyFocusStatusText: String {
        day.sessions.isEmpty ? "Keine Sessions" : "\(day.focusMinutes) \(minuteUnitText)"
    }

    private var focusRoundUnitText: String {
        day.focusWinCount == 1 ? "Session" : "Sessions"
    }

    private var minuteUnitText: String {
        day.focusMinutes == 1 ? "Minute Fokus" : "Minuten Fokus"
    }

    private var goalText: String {
        if day.didReachGoal {
            return "Tagesziel erreicht"
        }

        let remainingWins = store.dailyGoalSessions - day.focusWinCount
        let unit = remainingWins == 1 ? "Session" : "Sessions"
        return "Noch \(remainingWins) \(unit) bis zum Ziel"
    }

    private var blockerInsightText: String? {
        guard let primaryBlockerReason = day.primaryBlockerReason else {
            return nil
        }

        if let latestBlockerNextStep = day.latestBlockerNextStep {
            return "Blockiert: \(primaryBlockerReason.title) · Nächster Schritt: \(latestBlockerNextStep)"
        }

        return "Blockiert: \(primaryBlockerReason.title)"
    }

    private var hasOutcomeInsights: Bool {
        day.completedOutcomeCount > 0 || day.progressedOutcomeCount > 0 || day.blockedOutcomeCount > 0
    }

    private var topicSummaries: [PomodoroTopicSummary] {
        day.topicSummaries
    }

    private var orderedSessions: [PomodoroSession] {
        day.sessions.sorted { first, second in
            first.startedAt > second.startedAt
        }
    }

    private var totalTopicSeconds: TimeInterval {
        topicSummaries.reduce(0) { result, summary in
            result + summary.focusSeconds
        }
    }

    var body: some View {
        GlassEffectContainer(spacing: TimerTomatoDesign.panelSpacing) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.dayTitle(for: selectedDate))
                            .font(.callout)
                            .bold()

                        Text(dailyGoalSummaryText)
                            .font(.footnote)
                            .foregroundStyle(TimerTomatoDesign.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(dailyFocusStatusText)
                            .font(.footnote)
                            .foregroundStyle(TimerTomatoDesign.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }

                    Spacer(minLength: 10)

                    dailyGoalControl
                }

                if day.sessions.isEmpty {
                    HistoryEmptyStateView()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        metricRow
                        topicSummarySection
                        insightChips
                        blockerInsight
                        goalStatus
                        sessionTagSection
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .timerTomatoCard(.panel)
        }
    }

    private var dailyGoalControl: some View {
        HStack(spacing: 0) {
            StepperIconButton(
                title: "Tagesziel senken",
                systemImage: "minus",
                isDisabled: store.dailyGoalSessions <= PomodoroStore.minimumDailyGoalSessions,
                action: store.decreaseDailyGoalSessions
            )

            Text("\(store.dailyGoalSessions)")
                .font(.footnote.monospacedDigit())
                .bold()
                .frame(minWidth: 22)

            StepperIconButton(
                title: "Tagesziel erhöhen",
                systemImage: "plus",
                isDisabled: store.dailyGoalSessions >= PomodoroStore.maximumDailyGoalSessions,
                action: store.increaseDailyGoalSessions
            )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background {
            Capsule()
                .fill(TimerTomatoDesign.surfaceFill)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
    }

    private var metricRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(day.focusWinCount)")
                    .font(.system(.largeTitle, design: .rounded))
                    .monospacedDigit()
                    .bold()

                Text(focusRoundUnitText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
            }

            Divider()
                .frame(height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(day.focusMinutes)")
                    .font(.system(.largeTitle, design: .rounded))
                    .monospacedDigit()
                    .bold()

                Text(minuteUnitText)
                    .font(.footnote)
                    .foregroundStyle(TimerTomatoDesign.secondaryText)
            }
        }
    }

    @ViewBuilder
    private var topicSummarySection: some View {
        if !topicSummaries.isEmpty {
            VStack(alignment: .leading, spacing: 7) {
                Label("Themen", systemImage: "tag.fill")
                    .font(.footnote.bold())
                    .foregroundStyle(.primary)
                    .labelStyle(.titleAndIcon)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(topicSummaries.prefix(3))) { summary in
                        TopicSummaryRow(
                            summary: summary,
                            totalSeconds: totalTopicSeconds
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var insightChips: some View {
        if hasOutcomeInsights {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) {
                    if day.completedOutcomeCount > 0 {
                        insightChip("Erledigt \(day.completedOutcomeCount)", systemImage: PomodoroSessionOutcome.completed.systemImage, tint: TimerTomatoDesign.mint)
                    }

                    if day.progressedOutcomeCount > 0 {
                        insightChip("\(PomodoroSessionOutcome.progressed.shortTitle) \(day.progressedOutcomeCount)", systemImage: PomodoroSessionOutcome.progressed.systemImage, tint: TimerTomatoDesign.mint)
                    }

                    if day.blockedOutcomeCount > 0 {
                        insightChip("Blockiert \(day.blockedOutcomeCount)", systemImage: PomodoroSessionOutcome.blocked.systemImage, tint: TimerTomatoDesign.tomato)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    @ViewBuilder
    private var blockerInsight: some View {
        if let blockerInsightText {
            Label(blockerInsightText, systemImage: "exclamationmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.82)
        }
    }

    private var goalStatus: some View {
        Label(
            goalText,
            systemImage: day.didReachGoal ? "checkmark.circle.fill" : "target"
        )
        .font(.footnote)
        .foregroundStyle(day.didReachGoal ? TimerTomatoDesign.mint : TimerTomatoDesign.secondaryText)
    }

    private var sessionTagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Sessions", systemImage: "clock")
                .font(.footnote.bold())
                .foregroundStyle(.primary)
                .labelStyle(.titleAndIcon)

            VStack(spacing: 7) {
                ForEach(orderedSessions) { session in
                    sessionTagRow(for: session)
                }
            }
        }
    }

    @ViewBuilder
    private func sessionTagRow(for session: PomodoroSession) -> some View {
        if editingSessionID == session.id {
            sessionTagEditor(for: session)
        } else {
            Button {
                openSessionTagEditor(for: session)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "tag")
                        .font(.caption)
                        .foregroundStyle(TimerTomatoDesign.mint)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.intentTitle ?? "Ohne Tag")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(session.intentTitle == nil ? TimerTomatoDesign.secondaryText : .primary)
                            .lineLimit(1)

                        Text(sessionTimeRangeText(session))
                            .font(.caption2)
                            .foregroundStyle(TimerTomatoDesign.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "square.and.pencil")
                        .font(.caption2)
                        .foregroundStyle(TimerTomatoDesign.tertiaryText)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(TimerTomatoDesign.surfaceFill)
                }
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .help("Session-Tag bearbeiten")
        }
    }

    private func sessionTagEditor(for session: PomodoroSession) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(TimerTomatoDesign.mint)
                    .accessibilityHidden(true)

                TextField("Tag", text: $draftSessionIntent)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .lineLimit(1)
                    .focused($isSessionIntentFieldFocused)
                    .onSubmit {
                        applySessionTag(for: session)
                    }

                Button("Tag übernehmen", systemImage: "checkmark") {
                    applySessionTag(for: session)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(TimerTomatoDesign.mint)
                .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                .contentShape(Circle())
                .help("Tag übernehmen")

                Button("Abbrechen", systemImage: "xmark") {
                    closeSessionTagEditor()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(TimerTomatoDesign.tertiaryText)
                .frame(width: TimerTomatoDesign.compactHitTarget, height: TimerTomatoDesign.compactHitTarget)
                .contentShape(Circle())
                .help("Abbrechen")
            }

            HStack(spacing: 6) {
                Menu {
                    ForEach(PomodoroStore.focusIntentSuggestions, id: \.self) { suggestion in
                        Button(suggestion) {
                            draftSessionIntent = suggestion
                            applySessionTag(for: session)
                        }
                    }
                } label: {
                    Label("Vorschläge", systemImage: "list.bullet")
                        .font(.caption2)
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(TimerTomatoDesign.secondaryText)
                        .padding(.horizontal, 7)
                        .frame(height: 22)
                        .background {
                            Capsule()
                                .fill(TimerTomatoDesign.trackFill)
                        }
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .help("Tag-Vorschlag auswählen")

                Spacer(minLength: 0)

                if session.intentTitle != nil || !draftSessionIntent.isEmpty {
                    Button("Tag entfernen", systemImage: "xmark.circle") {
                        draftSessionIntent = ""
                        applySessionTag(for: session)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(TimerTomatoDesign.tertiaryText)
                    .frame(width: TimerTomatoDesign.compactHitTarget, height: 22)
                    .contentShape(Circle())
                    .help("Tag entfernen")
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(TimerTomatoDesign.surfaceFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(TimerTomatoDesign.mint.opacity(0.20), lineWidth: 0.7)
                }
        }
        .onExitCommand(perform: closeSessionTagEditor)
    }

    private func insightChip(_ title: String, systemImage: String, tint: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.bold())
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(TimerTomatoDesign.trackFill)
                    .overlay {
                        Capsule()
                            .fill(tint.opacity(0.08))
                    }
            }
    }

    private func sessionTimeRangeText(_ session: PomodoroSession) -> String {
        let start = session.startedAt.formatted(date: .omitted, time: .shortened)
        let end = session.endedAt.formatted(date: .omitted, time: .shortened)
        return "\(start) - \(end)"
    }

    private func openSessionTagEditor(for session: PomodoroSession) {
        draftSessionIntent = session.intentTitle ?? ""
        editingSessionID = session.id
        isSessionIntentFieldFocused = true
    }

    private func closeSessionTagEditor() {
        editingSessionID = nil
        draftSessionIntent = ""
        isSessionIntentFieldFocused = false
    }

    private func applySessionTag(for session: PomodoroSession) {
        store.updateSessionIntent(session.id, intent: draftSessionIntent)
        closeSessionTagEditor()
    }
}

private struct TopicSummaryRow: View {
    let summary: PomodoroTopicSummary
    let totalSeconds: TimeInterval

    private var progress: Double {
        guard totalSeconds > 0 else {
            return 0
        }

        return min(max(summary.focusSeconds / totalSeconds, 0), 1)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(PomodoroFormatters.topicTitle(summary.intent))
                .font(.caption)
                .foregroundStyle(TimerTomatoDesign.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(PomodoroFormatters.topicTitle(summary.intent))

            Spacer(minLength: 8)

            TimerProgressBarView(progress: progress, tint: TimerTomatoDesign.mint)
                .frame(width: 74, height: 4)

            Text(PomodoroFormatters.topicMinutesText(seconds: summary.focusSeconds))
                .font(.caption.monospacedDigit())
                .fontWeight(.semibold)
                .frame(width: 44, alignment: .trailing)
        }
    }
}

#if DEBUG
#Preview("Tagesdetails") {
    HistoryDayDetailView(
        store: TimerTomatoPreviewData.store(sessions: TimerTomatoPreviewData.historySessions),
        selectedDate: TimerTomatoPreviewData.referenceDate
    )
    .padding()
    .frame(width: TimerTomatoDesign.historyContentWidth)
}
#endif
