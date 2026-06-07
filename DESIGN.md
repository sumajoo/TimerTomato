# TimerTomato Design

## Design Intent

TimerTomato should feel like a calm macOS menu bar tool for small, realistic focus wins. The UI should be compact, readable, and quick to operate without turning focus tracking into a dashboard-heavy product.

## Source Of Truth

- Visual tokens and card treatment live in `TimerTomato/Design/TimerTomatoDesign.swift`.
- App composition lives in `TimerTomato/App/MenuBar`.
- Feature views live under `TimerTomato/Features`.
- Preview data lives in `TimerTomato/Support/TimerTomatoPreviewData.swift`.

## Layout

- The main menu bar surface uses `TimerTomatoDesign.contentWidth` (`340`).
- The history surface uses `TimerTomatoDesign.historyContentWidth` (`contentWidth + 36`).
- Root menu bar content uses `TimerTomatoDesign.contentPadding` (`16`).
- Keep fixed-format controls stable with explicit widths, heights, and min hit targets.
- Do not make the menu surface wider to solve copy problems unless the workflow truly requires more space.

## Cards And Surfaces

- Use `timerTomatoCard(.hero)` for the primary timer surface only.
- Use `timerTomatoCard(.panel)` for grouped secondary sections such as history summaries.
- Use `timerTomatoCard(.row)` for repeated compact rows and inline stats.
- Avoid cards inside cards. Prefer spacing, typography, and separators for hierarchy inside an existing panel.
- Use `GlassEffectContainer` and `.glassEffect` consistently with the current controls.

## Color Roles

- Tomato is the focus, urgency, and blocker color.
- Mint is the break, success, progress, and momentum color.
- Use `secondaryText` and `tertiaryText` for quiet supporting text.
- Add new color needs to `TimerTomatoDesign` instead of hard-coding one-off colors in feature views.
- All core colors should remain adaptive for light and dark appearances.

## Typography And Copy Density

- The countdown is the only hero-scale text.
- Use monospaced digits for times, counts, and compact numeric progress.
- Prefer `caption`, `caption2`, `footnote`, and `callout` inside the menu bar.
- Keep labels one-line where the UI is fixed width.
- If a label clips, shorten the content first. Use `minimumScaleFactor` as a backup, not as the main solution.

## Controls

- Primary timer actions use clear labels plus SF Symbols.
- Secondary actions can be icon-only when the symbol is standard and a `.help(...)` tooltip is present.
- Use `TimerTomatoDesign.minimumHitTarget` (`44`) for normal controls.
- Use `TimerTomatoDesign.compactHitTarget` (`34`) only for dense inline controls.
- Keep destructive or reset-style controls visually secondary unless the current state makes them the primary next action.
- Keep the focus checklist window compact, editable, and quieter than the countdown.
- Show checklist reminder times as quiet supporting text; retiming controls belong in edit mode.
- Keep checklist reminder mode controls in edit mode; the normal checklist view should stay focused on checking off steps.
- During an active focus, pause, or pending outcome, hide secondary dashboard surfaces and keep the hero focused on timer context.

## Motion

- Respect `accessibilityReduceMotion`.
- Keep transitions quick and subtle. Current menu transitions use short `.snappy` animations around status, session counts, focus wins, and screen changes.
- Avoid animation that makes the menu feel busy while a focus block is running.

## Previews

- Add a bottom-of-file `#Preview` for new SwiftUI views.
- Use `TimerTomatoPreviewData.store(...)` and existing sample sessions instead of ad hoc mock state.
- Preview at `TimerTomatoDesign.contentWidth` or `TimerTomatoDesign.historyContentWidth` so truncation issues are visible early.

## Visual Acceptance

Before finishing UI work, check:

- Main surface still reads as a compact menu bar app.
- Primary action is obvious for `idle`, `running`, and `paused`.
- Active focus shows only the timer, goal context, next checklist cue when available, and the primary timer action.
- The checklist window opens only for focus sessions with a goal and does not block timer controls.
- Pending outcome choices fit without wrapping awkwardly.
- Today and History surfaces show richer context without overwhelming the timer hero.
- Light and dark adaptive colors still have enough contrast.
