# Contributing to TimerTomato

Thank you for your interest in improving TimerTomato. The project is intentionally small, calm, and local-first, so contributions should keep the app easy to understand and maintain.

## How to Contribute

1. Open an issue before starting larger changes.
2. Create a focused branch from `main`.
3. Keep each pull request scoped to one problem or feature.
4. Add or update tests when touching domain, persistence, or summary logic.
5. Include screenshots or screen recordings for UI changes.
6. Run the verification commands before opening a pull request.

## Local Setup

Open the Xcode project:

```bash
open TimerTomato.xcodeproj
```

Build from the command line:

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

Run the store and domain test suite:

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

Check for whitespace issues:

```bash
git diff --check
```

## Code Style

- Prefer simple, explicit Swift.
- Keep domain behavior in `TimerTomato/Domain`.
- Keep SwiftUI views focused on layout and presentation.
- Match the existing compact menu bar design.
- Avoid broad refactors in feature pull requests.
- Do not add dependencies unless there is a clear, reviewed need.

## Signing and Xcode User State

The repository does not commit a personal Apple Developer Team ID.
If you need local signing or TestFlight uploads, set your team in Xcode locally, but do not commit that change.

Before committing, check:

```bash
git status --short
git diff TimerTomato.xcodeproj/project.pbxproj
```

If the only project-file change is your local signing team, restore it:

```bash
git restore TimerTomato.xcodeproj/project.pbxproj
```

Never commit:

- `xcuserdata`
- `*.xcuserstate`
- DerivedData or build products
- signing identities
- provisioning profiles
- local databases
- `.env` files

## Pull Request Checklist

Before requesting review:

- The change is focused and explained clearly.
- `git diff --check` passes.
- The app builds locally.
- Relevant tests pass.
- UI changes include screenshots or a short visual description.
- No local signing or Xcode user-state changes are included.
