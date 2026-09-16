# Pinball Neo 95 — Game Development Plan

## Vision

Pinball Neo 95 is a portrait dog-park pinball game with HD presentation, chunky pixel art, modern mobile controls, and the colorful arcade spirit of 1995 PC pinball games.

## Technology

- Flutter and Dart for the application and platform layer
- Flame for the game loop, sprites, animation, and input
- Forge2D for ball, flipper, bumper, ramp, and wall physics
- Android and iOS as primary platforms
- Windows as an additional desktop platform
- Original artwork, music, sound effects, names, and branding

## Visual and Screen Standard

- Portrait-first gameplay
- Logical game canvas around 360x640
- HD output scaled with nearest-neighbor filtering
- Crisp pixel art with no blurry filtering or anti-aliasing
- Support taller phone aspect ratios without cropping gameplay
- Use safe areas for notches, camera cutouts, and rounded screens

## Milestone 1 — Project Foundation

- Create the Flutter project
- Add Flame and Forge2D
- Set up the portrait game viewport
- Set up nearest-neighbor pixel rendering
- Add the main game scene
- Add a basic HUD layer
- Add keyboard, touch, and controller input abstractions

## Milestone 2 — Playable Prototype

- Build the outer playfield walls
- Add one physics-driven tennis ball
- Add left and right flippers
- Add the right-side launcher and plunger
- Add a drain area
- Add three placeholder paw bumpers
- Add one scoring target
- Add score, balls remaining, and restart controls

### Prototype completion criteria

The player can launch a ball, control both flippers, hit objects, score points, lose a ball, use all three balls, see game over, and restart.

## Milestone 3 — Core Game Systems

- Game states: ready, playing, paused, ball lost, game over
- Three-ball game rules
- Ball-save system
- High-score saving
- Score multipliers
- Target progress tracking
- Bonus timers
- Pause and restart menus
- Basic sound and vibration events

## Milestone 4 — Themed Table Features

Add and test features in this order:

1. Paw-print bumpers
2. Tennis-ball targets
3. Bone ramps
4. Doghouse lane
5. Fire-hydrant spinner
6. Chew-toy scoring targets
7. Water-bowl bonus
8. Mission system
9. Multiball mode

## Milestone 5 — Presentation

- Replace placeholder shapes with final pixel sprites
- Add animated lights and target states
- Add pixel particle effects
- Add ball trails and impact flashes
- Add screen shake for major hits
- Add original arcade music
- Add barking, squeaking, bouncing, launching, and drain sounds
- Add title screen, controls screen, settings, credits, and game-over screens

## Milestone 6 — Mobile and Desktop Release

- Tune touch zones for left- and right-handed play
- Add optional haptic feedback
- Test Android, iOS, and Windows builds
- Test small, large, and extra-tall screens
- Optimize texture memory, particles, and battery usage
- Add local save data for settings and high scores
- Prepare release builds and store assets

## Scope Rule

Every new feature must first be playable with placeholder art, then receive final art, audio, and polish after the gameplay works.

The detailed, checkbox-based sequence for the missing ball loop, touch controls, bumpers, slingshots, ramps, habitrails, background, and device verification is in [GAMEPLAY_IMPLEMENTATION_PLAN.md](GAMEPLAY_IMPLEMENTATION_PLAN.md).
