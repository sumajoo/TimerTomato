# TimerTomato User Flows

## Flow Source Of Truth

`TimerTomato/Domain/PomodoroStore.swift` owns timer state, permissions, persistence, goals, pending outcomes, rescue focus, and history summaries. Views should render the store state and call explicit store methods rather than duplicating flow logic.

## Menu Bar Navigation

The app has two menu bar screens:

- `MenuBarScreen.main`: header, timer hero with duration buttons and presets, and today's sessions.
- `MenuBarScreen.history`: weekly navigation, weekly quest summary, and selected-day detail.

The calendar button in `MenuBarHeaderView` opens History and seeds `selectedHistoryDate` with `store.currentDate`. The History back button returns to the main screen. Keep this navigation shallow and explicit.

## Goal Checklist Flow

Goal checklists are optional per-goal todos that appear after a focus timer starts:

1. User chooses a focus goal such as `Lernen`.
2. `store.start()` starts the timer through the normal focus guard.
3. If the focus session has a goal, the app opens the small `Fokus-Checklist` window.
4. The window shows the saved checklist template for that goal, with all items unchecked for the new session.
5. Each item can have a minute offset such as `Jetzt`, `3 min`, or `6 min`.
6. Each checklist has a reminder mode: `Normal` schedules reminders with sound, `Leise` schedules silent reminders, and `Aus` disables checklist reminders.
7. While focus runs, the main timer can show the next open checklist cue such as `Jetzt: Buch öffnen` or `In 3 min: 3 Stichpunkte machen`.
8. User can check, edit, delete, add, retime steps, or change the reminder mode while the timer runs.

Checklist templates are local and goal-specific. `Lernen` defaults to `Buch öffnen`, `Inhalt lesen`, `3 Minuten laut sagen "Worum geht es hier überhaupt"`, and `3 Stichpunkte machen` with reminders at `Jetzt`, `1 min`, `3 min`, and `6 min`. Goals without a saved template start with an empty checklist.

## Main Focus Flow

1. User starts from `idle`.
2. User can choose a duration with the plus/minus buttons beside the timer or the preset chips below it.
3. User can choose a focus intent from suggestions or type a custom intent.
4. `store.start()` starts a focus timer only when `canStartFocus` is true.
5. The pending intent becomes the active focus intent, then the pending field is cleared.
6. While focus is running, the user can pause, reset, or change the active focus intent.
7. When the focus timer completes, a session is persisted and the app enters pending outcome.

## Active Timer Flow

- `running` shows progress and a pause action.
- `paused` shows the remaining time and a continue action.
- Active focus and pause keep the main menu surface focused on timer context, goal context, and the next checklist cue when available.
- Reset returns to `idle`, clears active timer fields, and does not create a completed session.
- Focus uses tomato accenting. Break uses mint accenting.
- The active focus topic can change only while a focus timer is active and no pending outcome exists.

## Pending Outcome Flow

After a focus session completes, the app must ask what happened before another focus or break starts.

Outcome options:

- Completed: save as a focus win.
- Progressed: save as a focus win.
- Blocked: ask for the smallest next step first, with optional blocker reason behind `Grund hinzufügen`, then save as blocked.

Pending outcome should block normal start and break actions. Do not introduce shortcuts that silently skip this step.

## Feedback And Continuation

Completion feedback is intentionally short:

- Focus wins summarize today and week progress.
- Progressed sessions can offer "continue with topic".
- Blocked sessions can offer a 10-minute reset when `canStartFocus` is true.

Keep feedback compact enough for the main menu width. Richer explanation belongs in History.

## Break Flow

After at least one completed session and no pending outcome, `canStartBreak` enables a 5-minute break.

Break flow:

1. User starts break from the idle main timer controls.
2. Break runs with mint accenting.
3. User can pause, resume, or reset the break.
4. Completed break returns to `idle` and notifies the user.

Breaks do not replace the pending outcome step after a focus completion.

## Rescue Focus Flow

Rescue focus is a short recovery path, currently 10 minutes with the intent `Kurz dranbleiben`.

It can be offered from blocked feedback or the weekly quest surface when the store says the user can start focus and momentum needs a small recovery action.

Rules:

- Keep rescue clearly smaller than normal focus.
- Do not auto-start rescue without an explicit user action.
- Preserve rescue metadata so History can distinguish reset-style sessions.

## Today Surface

The main screen keeps today's goal progress visible near the timer context.
The Today section below it is only the recent-session list, newest first.

Goal editing and richer topic detail belong in History.

## History Flow

History is the richer review surface:

- Week navigation changes `selectedDate` by week.
- The week calendar selects a day.
- Weekly summary shows weekly quest progress, momentum, blockers, best focus days, and optional goal suggestion.
- Day detail shows focus wins, focus minutes, topics, outcomes, blockers, rescue sessions, and goal status.

History can carry more context than the main timer, but it should still remain one compact menu panel.

## Flow Change Checklist

Before changing behavior, verify:

- Store guards still prevent invalid starts.
- Pending outcome cannot be skipped accidentally.
- Existing session persistence still records completed focus sessions.
- Goal checklist templates survive app restore.
- Active checklist completion state survives app restore while a focus timer is running.
- Rescue sessions remain distinguishable from normal sessions.
- Main and History screens still have a single obvious next action.
- Domain tests cover changed calculations, persistence, or exact copy.
