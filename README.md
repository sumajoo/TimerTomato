# TimerTomato

TimerTomato is a calm macOS menu bar Pomodoro app built with SwiftUI and SwiftData.
It is designed around small, realistic focus wins: set a lightweight intent, run a focus block, reflect on the outcome, and keep momentum visible without turning productivity into pressure.

## Highlights

- Menu bar first Pomodoro timer for macOS
- Custom focus durations and quick duration presets
- Optional session intent before starting a focus block
- Per-goal focus checklist window with editable local templates and timed reminders
- Focus Wins outcome flow: completed, progressed, or blocked
- Weekly Quest, daily goals, streaks, momentum, and rescue focus sessions
- Local history with day and week summaries
- Local notifications for focus, break, and checklist reminders
- SwiftData-backed local persistence

## Requirements

- macOS with the SDK version configured in the Xcode project
- Xcode with Swift 6 support
- No third-party package dependencies

## Getting Started

Clone the repository:

```bash
git clone git@github.com:sumajoo/TimerTomato.git
cd TimerTomato
```

Open the project in Xcode:

```bash
open TimerTomato.xcodeproj
```

Then:

1. Select the `TimerTomato` scheme.
2. Choose `My Mac` as the run destination.
3. Press `Cmd + R`.

You can also build from the command line:

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

Run the test suite:

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

## Signing, TestFlight, and Local Development

The repository intentionally does not commit a personal Apple Developer Team ID.
For local signing, TestFlight, or App Store uploads:

1. Open `TimerTomato.xcodeproj` in Xcode.
2. Select the `TimerTomato` target.
3. Go to `Signing & Capabilities`.
4. Choose your Apple Developer Team.
5. Archive and upload through Xcode Organizer.

Xcode may write your local team setting into `TimerTomato.xcodeproj/project.pbxproj`.
Do not commit that personal signing change. Before committing, check:

```bash
git status --short
git diff TimerTomato.xcodeproj/project.pbxproj
```

If the only change is your local signing team, restore it before committing:

```bash
git restore TimerTomato.xcodeproj/project.pbxproj
```

## Project Structure

```text
TimerTomato/
  App/             App entry and menu bar composition
  Design/          Shared visual constants and card styling
  Domain/          Pomodoro models, summaries, and store logic
  Features/        SwiftUI feature views
  Notifications/   User notification abstraction and scheduler
  Persistence/     SwiftData models and container setup
  Resources/       Asset catalogs
  Support/         Formatting, previews, and helper data
TimerTomatoTests/  Store and domain tests
TimerTomatoUITests/
```

## Contributing

Contributions are welcome. Please keep changes small, focused, and easy to review.
Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

Before opening a pull request:

1. Create a focused branch from `main`.
2. Keep unrelated cleanup out of the same PR.
3. Follow the existing SwiftUI style and file organization.
4. Add or update tests for domain and persistence behavior.
5. Run `git diff --check`.
6. Run the build and relevant tests with the commands above.

Code guidelines:

- Prefer simple, explicit Swift over clever abstractions.
- Keep app logic in the domain/store layer and views focused on presentation.
- Preserve the calm, compact menu bar experience.
- Do not commit Xcode user state, DerivedData, signing identities, provisioning profiles, local databases, or `.env` files.

## Privacy

TimerTomato is a local-first app. Focus sessions and settings are stored locally on the user's Mac through SwiftData and app storage.

## Security

Please report suspected security or privacy issues privately. See [SECURITY.md](SECURITY.md).

## License

TimerTomato is released under the MIT License. See [LICENSE](LICENSE).
