# AGENTS.md

## Operating Mode

Act like a high-performing senior engineer. Be concise, direct, and execution-focused.

Prefer simple, maintainable, production-friendly solutions. Write low-complexity code that is easy to read, debug, and modify.

Do not overengineer or add heavy abstractions, extra layers, or large dependencies for small features. Keep APIs small, behavior explicit, and naming clear. Avoid cleverness unless it clearly improves the result.

## Read First

- Read `README.md` and `CONTRIBUTING.md` for the project shape, setup, and verification commands.
- Read `DESIGN.md` before UI, layout, copy-density, color, motion, or component changes.
- Read `USER_FLOWS.md` before behavior, navigation, timer-state, history, outcome, rescue, or goal changes.
- Use `TimerTomato/Design/TimerTomatoDesign.swift` as the visual source of truth.
- Use `TimerTomato/Domain/PomodoroStore.swift` as the timer and flow source of truth.
- Use `TimerTomato/Support/TimerTomatoPreviewData.swift` for realistic SwiftUI previews.

## Repo Facts

- TimerTomato is a local-first macOS menu bar app built with SwiftUI and SwiftData.
- The app has no third-party package dependencies today.
- If package tooling is ever introduced, use `pnpm` instead of `npm`, and never install packages younger than 3 days.
- Xcode uses file-system-synchronized groups, so adding Swift files under existing synced groups should not require manual `.pbxproj` edits.
- Do not commit local signing teams, `xcuserdata`, DerivedData, build outputs, provisioning profiles, local databases, or `.env` files.

## SwiftUI View Order

- Environment
- `@State` / `@Binding`
- variables
- computed properties
- init
- body
- helper functions

## Engineering Rules

- Keep domain behavior in `TimerTomato/Domain`.
- Keep SwiftUI views focused on layout, presentation, and local interaction wiring.
- Keep shared styling in `TimerTomato/Design/TimerTomatoDesign.swift`.
- Split large SwiftUI surfaces by responsibility before they become hard to scan.
- Add a bottom-of-file `#Preview` for newly added SwiftUI views unless the view cannot be previewed safely.
- Keep UI copy short enough for the compact menu bar width. If text clips, prefer shortening source copy over adding layout complexity.
- Update tests when changing domain behavior or exact strings asserted by `TimerTomatoTests`.

## Design Rules

- Preserve the calm, compact menu bar experience.
- Use `TimerTomatoDesign` tokens and `timerTomatoCard` instead of one-off styling.
- Use the existing tomato focus color and mint success/break color roles.
- Keep the main timer surface restrained; put richer narrative, trends, and summaries in Today or History surfaces.
- Avoid nested cards and broad decorative redesigns.
- Respect `TimerTomatoDesign.minimumHitTarget` for primary interactive controls.

## Flow Rules

- Do not bypass store guards such as `canStartFocus`, `canStartBreak`, and `canChangeActiveFocusIntent`.
- Preserve the pending outcome step after a completed focus session; new focus or break actions should not skip it.
- Treat rescue focus as a short recovery path, not as a replacement for the normal focus flow.
- Keep main and history navigation explicit: `MenuBarScreen.main` and `MenuBarScreen.history`.

## Verification

Run whitespace validation:

```bash
git diff --check
```

Build:

```bash
xcodebuild \
  -project TimerTomato.xcodeproj \
  -scheme TimerTomato \
  -configuration Debug \
  -destination platform=macOS \
  -derivedDataPath /tmp/TimerTomatoDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Run the focused test suite:

```bash
xcodebuild \
  -project TimerTomato.xcodeproj \
  -scheme TimerTomato \
  -configuration Debug \
  -destination platform=macOS \
  -derivedDataPath /tmp/TimerTomatoDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  test -only-testing:TimerTomatoTests
```
