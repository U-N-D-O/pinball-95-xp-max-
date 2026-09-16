# Pinball Neo 95 Physical-Device QA Runbook

This runbook covers checks that cannot be proven by desktop widget tests or a release build. Run it on a physical Android phone before the first public release, then repeat on iOS when the project is opened on macOS/Xcode.

## Test setup

1. Install the release build, not a debug build.
2. Use portrait orientation and disable battery-saver restrictions for the test session.
3. Test one compact phone and one large or extra-tall phone. Include a device with a camera cutout or rounded corners when possible.
4. Keep the test volume low at first. Enable sound and haptics for the normal pass.
5. Record the device model, OS version, build version, and result for every case.

## Core play sequence

| ID | Action | Pass condition |
| --- | --- | --- |
| D01 | Launch the app | The Pinball Neo 95 title screen fits the portrait display with no clipped text or controls. |
| D02 | Tap START GAME | The table opens and the game responds without a visible frame stall. |
| D03 | Press both lower flipper zones repeatedly | Each flipper responds independently; releasing a finger releases only that flipper. |
| D04 | Tap the launcher lane | The ball launches once and cannot be launched again while already in play. |
| D05 | Play until a drain | The ball returns safely to the launcher and the ball count changes exactly once. |
| D06 | Drain three balls | Game-over feedback appears and the restart control starts a clean session. |
| D07 | Pause and resume | Physics stops while paused and resumes only after the player taps RESUME. |
| D08 | Open settings | Audio mute, volume, and haptic feedback controls are readable and touchable. |

## Mobile-specific checks

- Rotate the device or attempt rotation during play; the game remains portrait and does not distort.
- Test touch zones near the bottom safe area and around a home indicator.
- Test left and right flippers with one finger, two fingers, and alternating fingers.
- Toggle mute, volume, and haptic feedback; close settings, relaunch, and confirm all three choices persist.
- Background the app during active play, lock the screen, and return. The game must remain paused until RESUME is tapped.
- Confirm haptics are noticeable but not excessive on flippers, launches, bumpers, bonuses, and drains.
- Confirm audio has no crackle, stuck loop, extreme volume jump, or sound after mute.

## Gameplay verification

- Hit a red bumper, blue bumper, scoring target, chew toy, hydrant, water bowl, paw mission target, and doghouse lane.
- Confirm each feature scores once per intended contact/cooldown and displays its feedback.
- Complete the paw mission in order and verify the doghouse bonus.
- Activate the water save, drain the ball, and verify the save protects one drain.
- Play long enough to check that the ball remains controllable and does not gain runaway speed.
- Relaunch the app after recording a high score and confirm the best score remains.

## Evidence to record

For every failure, record:

- Device model and OS version
- App version from `game_app/pubspec.yaml`
- Exact reproduction steps
- Whether sound, haptics, or backgrounding was involved
- Screen recording or screenshot, when useful

## Current environment limitation

The development machine currently has Windows and Edge targets available but no connected physical phone or emulator. Therefore the automated and desktop portions are complete, while the device cases in this document remain pending until hardware is connected.
