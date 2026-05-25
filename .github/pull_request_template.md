## Summary

Describe what changed and why.

## Screenshots or Recording

Add screenshots or a short recording for UI changes.

## Test Plan

- [ ] `git diff --check`
- [ ] `xcodebuild -project TimerTomato.xcodeproj -scheme TimerTomato -configuration Debug -destination platform=macOS -derivedDataPath /tmp/TimerTomatoDerivedData CODE_SIGNING_ALLOWED=NO build`
- [ ] `xcodebuild -project TimerTomato.xcodeproj -scheme TimerTomato -configuration Debug -destination platform=macOS -derivedDataPath /tmp/TimerTomatoDerivedData CODE_SIGNING_ALLOWED=NO test -only-testing:TimerTomatoTests`

## Repository Hygiene

- [ ] No local signing team changes are included
- [ ] No `xcuserdata`, DerivedData, build outputs, provisioning profiles, or local databases are included
- [ ] Documentation was updated if behavior changed
