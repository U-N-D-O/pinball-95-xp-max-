# Pinball Neo 95 — Testing and Improvement Plan

## Testing Goals

The game must be reliable, responsive, readable, fun, and smooth on phones while preserving crisp pixel art.

## Physics Testing

Check every build for:

- Ball never becoming permanently stuck
- Ball never passing through walls or flippers
- Flippers responding immediately
- Launcher working every time
- Bumpers producing predictable rebounds
- Ramps routing the ball correctly
- No unfair drain behavior
- Ball-save activation working correctly
- Multiball balls remaining independent
- Stable behavior at different frame rates

## Input Testing

Test:

- Left and right touch zones
- Tap and hold behavior
- Launcher touch control
- Keyboard controls
- Controller controls
- Left-handed control layout
- Accidental touches near pause buttons
- Input after pause and resume
- Input after game over and restart

## Screen and Visual Testing

Test:

- Small Android phones
- Mid-range Android phones
- Modern iPhones
- Large phones
- Extra-tall screens
- Windows desktop windows
- Different aspect ratios
- Notches and camera cutouts
- Safe-area spacing
- Pixel art at every supported scale
- No blur, stretching, or cropped table features

## Performance Testing

Targets:

- Stable 60 FPS
- No visible frame stutter during multiball
- Fast startup
- Reasonable memory use
- No excessive battery drain
- No audio crackling
- Particles and screen effects remain affordable on mid-range phones

Profile on physical Android and iOS devices, not only the development computer.

## Gameplay Balance Testing

Record:

- Average game length
- Average score
- Number of drains per game
- Time needed to complete missions
- Frequency of multiball
- Ball-save usefulness
- Flipper difficulty
- Whether players understand targets and bonuses
- Whether the launcher feels rewarding

Adjust one gameplay value at a time and test again.

## Usability Testing

Ask new players to play without instructions and observe:

- Can they find the launcher?
- Do they understand the flippers?
- Can they identify targets?
- Do they understand the score and ball counter?
- Do they know why a bonus activated?
- Do they know what caused game over?

Fix confusing visual communication before adding more features.

## Bug Priority

### Critical

- Crash
- Data loss
- Ball permanently stuck
- Game cannot start or restart
- Physics collision failure

### High

- Flipper input failure
- Launcher failure
- Major scoring error
- Broken mission or multiball system
- Severe performance problems

### Medium

- Incorrect animation
- Sound or vibration issue
- UI overlap
- Minor physics imbalance

### Low

- Cosmetic pixel mismatch
- Minor spacing issue
- Nonessential visual effect problem

## Improvement Cycle

For every test build:

1. Play several complete games.
2. Test the new feature directly.
3. Record bugs, confusing moments, and fun moments.
4. Fix critical and high-priority issues first.
5. Tune controls and physics.
6. Tune scoring and difficulty.
7. Improve visual and audio feedback.
8. Test again on a physical phone.
9. Keep the build only if it is at least as fun and reliable as the previous build.

## Release Gates

### Prototype Gate

The complete launch, play, drain, score, and restart loop works.

### Feature Gate

All planned table features work with placeholder or temporary art.

### Art Gate

Final sprites and animations are integrated and stylistically consistent.

### Mobile Gate

The game is comfortable to play on multiple phones at 60 FPS.

### Release Gate

No critical bugs remain, saves work, menus work, audio works, and Android, iOS, and Windows builds are ready.
