# Pinball Neo 95 Release Checklist

## Automated checks

- [x] `flutter analyze` reports no issues.
- [x] `flutter test` passes all tests.
- [x] Android debug and release APKs build successfully.
- [x] Android release App Bundle builds successfully.
- [x] Windows debug and release builds complete successfully.
- [x] [Release artifact audit](game_app/tool/verify_release_artifacts.ps1) passes after a release build.
- [x] Cross-platform identity, orientation, and icon metadata audit passes.
- [x] Cross-platform version and build-number metadata audit passes.
- [x] Android and iOS production identifiers are checked by the release audit.
- [x] Settings switches expose usable labels to accessibility services.
- [x] Release SHA-256 checksum manifest is generated for distributable binaries.
- [x] Manual GitHub Actions workflow is defined for an unsigned iOS test IPA.
- [x] GitHub unsigned IPA workflow completed successfully and its artifact checksum was verified.
- [x] Hosted GitHub CI workflow is configured for analysis and tests.
- [x] Repeatable release pipeline is available at `game_app/tool/build_release.ps1`.

## Device QA

- Follow [DEVICE_QA_RUNBOOK.md](DEVICE_QA_RUNBOOK.md) for the physical-device pass.
- [ ] Test on a physical Android phone in portrait mode.
- [ ] Test touch flippers, launcher, pause, settings, and game-over restart.
- [ ] Confirm sound effects, mute, and volume behavior.
- [ ] Confirm app pauses when backgrounded and resumes safely.
- [ ] Test a small phone and a large phone for safe-area/layout issues.

## Gameplay QA

- [ ] Launch ball and complete a full ball drain cycle.
- [ ] Verify bumper, target, toy, paw, hydrant, water, and doghouse scoring.
- [ ] Verify high score persists after relaunch.
- [ ] Verify achievements and new-record feedback reset correctly.
- [ ] Verify the ball never exceeds the intended speed envelope.

## Release polish

- [ ] Replace any placeholder sound mix with the final mastered mix.
- [x] Document the origin and current licensing status of sprite, audio, and icon assets.
- [ ] Complete final asset-terms review.
- [x] Archive generated dependency license notices with the release materials.
- [x] Set production app icon, display name, and version.
- [ ] Configure production signing for Android and iOS.
- [x] Document production signing setup without storing secrets.
- [ ] Capture final portrait screenshots for store listings.

## Distribution policy

- [x] Document the current local-only data behavior.
- [ ] Recheck privacy requirements if analytics, advertising, online services, or store SDKs are added.
