# Pinball Neo 95 — Gameplay Implementation Plan

This is the implementation plan for turning the current attractive table presentation into a complete, touch-playable pinball game.

The plan is deliberately incremental. Each step must be completed and tested before the next step begins. Placeholder shapes are acceptable during physics work; final pixel art is added after the behavior is correct.

## Status and evidence rules

- `[x]` means the source implementation for the item is complete.
- `[ ]` means it is not implemented yet, is incomplete, or is intentionally deferred.
- A code scaffold is not the same as a finished implementation. A feature is checked when its planned source work is complete.
- The attached iPhone screenshot is treated as a visual status reference and user feedback, not as an instruction document.
- Physical-device and final QA checks remain separate and stay unchecked until the implementation phases are complete.

## Deferred testing policy

Testing is intentionally deferred while the feature set is being built. During implementation, keep the code organized around the acceptance criteria and update the checkboxes when each source step is complete. After the final implementation checkbox is complete, run the automated suite, physical-device matrix, and full manual acceptance script in Phase 14–15.

## 1. Current evaluation

### 1.1 What is already in place

- [x] Flutter/Dart project structure exists in `game_app`.
- [x] Flame game loop and Forge2D integration are present.
- [x] Portrait-first logical playfield is configured around 360×640.
- [x] Pixel-art rendering and nearest-neighbor presentation are established.
- [x] Loading screen and current table presentation are visually strong on the tested iPhone build.
- [x] HUD, pause, settings, score, balls, and basic table presentation are present.
- [x] The code contains initial world objects for walls, bumpers, targets, ramps, launcher, flippers, and drain.
- [x] Keyboard input scaffolding exists for desktop development.
- [x] Touch input scaffolding exists for launcher and flipper zones.
- [x] Android, iOS, and Windows build validation exists in the repository.

### 1.2 Implementation status

These marks describe source implementation progress. Final automated and device verification is intentionally deferred until the implementation plan is complete.

- [x] A visible ball is wired to the launch-lane starting position.
- [x] A ball can be created and parked at the beginning of a turn.
- [x] Gravity, velocity limits, collision response, and bounce tuning are implemented in source.
- [x] The plunger can be pulled down by dragging and released to launch the ball.
- [x] Holding the left side of the screen holds the left flipper up.
- [x] Holding the right side of the screen holds the right flipper up.
- [x] Multi-touch allows both flippers to be held at the same time.
- [ ] A drained ball is removed, a life is deducted, and the next turn is handled.
- [x] Bumpers visibly and physically bounce the ball in source.
- [x] Slingshots provide a distinct angled kick and readable feedback in source.
- [ ] Ramps have working entrances, exits, sensors, and unique rules.
- [ ] Habitrails have working elevated routes and anti-stuck behavior.
- [ ] The playfield has its complete background sprite and final composition.

### 1.3 Final verification status

- [ ] Install the completed implementation on iPhone and verify the full play loop.
- [ ] Run the automated suite after all implementation phases are complete.
- [ ] Run the Android, iOS, and Windows device/build matrix.

### 1.4 Immediate focus

The next playable milestone is not the complete art pass. It is the **Core Ball Loop**:

1. Create and display one ball.
2. Launch it with the plunger.
3. Keep it moving with walls and bumpers.
4. Control both flippers by touch and hold.
5. Drain it, count the lost ball, and restart the turn.

Everything else depends on this loop being reliable.

## 2. Working rules for every increment

- [ ] Work on one numbered step at a time.
- [ ] Before coding, write the step's acceptance test in the task notes or commit message.
- [ ] Use a simple placeholder shape before commissioning or generating final art.
- [ ] Keep world coordinates independent from device pixels.
- [ ] Keep physics bodies separate from decorative sprites.
- [ ] Give every interactive object a stable type or ID for scoring and debugging.
- [ ] Tune one physics variable at a time and record the result.
- [ ] Never hide a physics problem with an animation or visual effect.
- [ ] Test portrait safe areas, small phones, large phones, and multi-touch behavior.
- [ ] Keep the game playable when audio, haptics, or decorative effects are disabled.
- [ ] Do not mark a checkbox complete merely because the app builds.

## 3. Master dependency order

The implementation order is:

1. Baseline and diagnostics
2. Physics world and collision contracts
3. Ball creation and visible ball state
4. Plunger drag-and-release launch
5. Flipper press, hold, release, and multi-touch
6. Drain, lives, ball reset, and restart
7. Bumper family and bounce tuning
8. Slingshot family and bounce tuning
9. Lower playfield safety geometry
10. Ramps and their unique behaviors
11. Habitrails and their unique behaviors
12. Scoring, rules, feedback, and ball save
13. Background and complete sprite composition
14. Audio, haptics, particles, and polish
15. Device QA, performance, and release regression

Do not move ramps or habitrails ahead of the verified ball loop. They are more difficult to debug when the base collision and reset behavior are still uncertain.

## 4. Phase 0 — Baseline and diagnostics

### Step 0.1 — Capture the current baseline

- [ ] Build the current release configuration.
- [ ] Install it on the reference iPhone.
- [ ] Record whether the loading screen, HUD, table, launcher, and existing objects appear.
- [ ] Record the current orientation, safe-area margins, and usable playfield rectangle.
- [ ] Capture a short baseline video before gameplay changes.
- [ ] Record the device model, iOS version, screen size, and build number.

**Done when:** the current visual state can be compared against every later build.

### Step 0.2 — Add a development diagnostics mode

- [ ] Add a debug-only toggle for drawing physics shapes.
- [ ] Add a debug-only toggle for drawing object IDs and sensor names.
- [ ] Add a debug-only FPS and physics-step indicator.
- [ ] Add a debug-only ball velocity display.
- [ ] Add a debug-only collision-event log with a small on-screen buffer.
- [ ] Ensure all diagnostics are disabled in release builds.

**Done when:** a collision or input problem can be located without guessing from the artwork.

### Step 0.3 — Establish reproducible test starts

- [ ] Add a deterministic development seed for object placement and effects.
- [ ] Add a debug action that starts with one ball and unlimited test lives.
- [ ] Add a debug action that places the ball at named test positions.
- [ ] Add a debug action that resets the table without restarting the app.
- [ ] Document how to reproduce each physics test from a clean state.

**Done when:** the same bug can be reproduced from the same starting state.

## 5. Phase 1 — Physics world foundation

### Step 1.1 — Define the world coordinate contract

- [ ] Document the logical table rectangle and launcher-lane rectangle.
- [ ] Document the top, bottom, left, and right boundaries in world coordinates.
- [ ] Document the lower drain opening and the flipper operating region.
- [ ] Define the conversion between Flame positions and Forge2D positions.
- [ ] Add assertions for objects placed outside the playable rectangle.

**Done when:** every physics object has an unambiguous world-space position on every phone.

### Step 1.2 — Define collision categories

- [ ] Create named collision categories for ball, wall, flipper, bumper, slingshot, ramp, habitrail, target, sensor, and drain.
- [ ] Define which categories collide physically.
- [ ] Define which categories only generate sensor events.
- [ ] Prevent decorative sprites from accidentally becoming colliders.
- [ ] Add tests for the category/filter matrix.

**Done when:** collision behavior is controlled by a documented table instead of incidental fixture settings.

### Step 1.3 — Stabilize the simulation loop

- [ ] Use a fixed physics time step independent of render frame rate.
- [ ] Cap the maximum catch-up time after an app pause or frame hitch.
- [ ] Prevent tunneling through thin walls at high ball velocity.
- [ ] Confirm that physics pauses when the game is paused.
- [ ] Confirm that physics resumes once, without a launch impulse, after unpausing.
- [ ] Measure the physics step cost on the reference iPhone.

**Done when:** the same launch produces materially similar motion at 30, 60, and 120 Hz.

### Step 1.4 — Build the outer table geometry

- [ ] Replace any temporary boundary assumptions with explicit left and right walls.
- [ ] Add the upper wall and launcher-lane separation.
- [ ] Add sloped lower guides with continuous collision edges.
- [ ] Add the lower apron and drain boundaries.
- [ ] Verify that no wall has a gap at corners or at the launcher lane.
- [ ] Draw the debug outlines over the current table art.

**Done when:** a test ball cannot leave the table except through the intended drain.

## 6. Phase 2 — Ball creation and visible ball state

### Step 2.1 — Create the ball model

- [x] Create a single authoritative ball state with ID, position, velocity, and active flag.
- [x] Give the ball a circular dynamic Forge2D body.
- [x] Set a stable radius in logical units.
- [x] Set the initial density, restitution, friction, and linear damping as named tuning constants.
- [x] Prevent the ball from rotating visually unless that rotation is intentionally rendered.

**Done when:** one ball is created by code and its body is visible and tracked.

### Step 2.2 — Create the tennis-ball sprite

- [x] Add a readable bright tennis-ball placeholder before final art.
- [x] Add the final pixel sprite at a source resolution that scales cleanly.
- [x] Use nearest-neighbor filtering.
- [x] Align the sprite center to the physics body center.
- [ ] Add a subtle seam animation only after the static ball is correctly aligned.
- [ ] Verify the ball remains visible against every current table color.

**Done when:** the player can clearly see the ball in the launcher and during motion on iPhone.

### Step 2.3 — Define ball lifecycle states

- [ ] Add `ready`, `inLauncher`, `launching`, `inPlay`, `draining`, and `removed` states.
- [ ] Prevent duplicate balls during rebuild, pause, orientation changes, or repeated taps.
- [ ] Prevent flippers and scoring objects from acting on a removed ball.
- [ ] Add an explicit `spawnBallForTurn()` method.
- [ ] Add an explicit `removeBallAfterDrain()` method.

**Done when:** every ball has one clear owner and one clear lifecycle transition.

## 7. Phase 3 — Plunger and spring launch

The current launcher has tap-to-launch scaffolding. It must become a real press, drag, hold, and release interaction.

### Step 3.1 — Define plunger geometry and range

- [x] Define the plunger's rest position.
- [x] Define the maximum downward pull distance.
- [x] Define the minimum pull distance that counts as a launch.
- [x] Define the launcher lane's ball capture region.
- [x] Define the launch direction and a safe maximum launch speed.
- [x] Keep the plunger inside the lane at every device aspect ratio.

**Done when:** the plunger range is consistent in logical coordinates and cannot be dragged sideways.

### Step 3.2 — Implement touch drag state

- [x] Detect pointer down only inside the plunger control region.
- [x] Store the pointer ID that owns the plunger.
- [x] Convert pointer movement into downward pull distance.
- [x] Clamp pull distance between zero and the maximum.
- [x] Ignore horizontal movement for the spring calculation.
- [x] Keep the plunger pulled while the owning pointer remains down.
- [x] Ignore other pointers until the owning pointer is released or canceled.

**Done when:** dragging downward visibly pulls the plunger and holding keeps it pulled.

### Step 3.3 — Implement release launch

- [x] On pointer release, convert pull distance into launch impulse.
- [x] Apply the impulse once to the captured ball.
- [x] Return the plunger to rest with a short spring animation.
- [x] Play the launch sound and optional haptic only once per launch.
- [ ] Release the pointer capture on cancel, app pause, focus loss, or drag leaving the control.
- [x] Decide and document whether a canceled drag launches; default to no launch.

**Done when:** a short pull gives a short launch, a full pull gives a strong launch, and repeated release events cannot double-launch.

### Step 3.4 — Handle launcher edge cases

- [ ] Prevent launching when there is no ball in the launcher.
- [ ] Prevent a second launch while the ball is already in play.
- [ ] Recover if the ball is detected below the launcher but above the drain.
- [ ] Recover the plunger after an app interruption.
- [ ] Verify the launch works with a mouse on Windows for development.
- [ ] Verify the launch works with a finger on the reference iPhone.

**Done when:** the plunger can complete at least 30 consecutive launches without a stuck state or duplicate ball.

## 8. Phase 4 — Mobile flipper controls

### Step 4.1 — Define the touch control layout

- [x] Define left and right touch regions in screen space.
- [x] Exclude HUD buttons, pause, settings, and the plunger from flipper regions.
- [x] Account for top and bottom safe areas.
- [x] Make the active regions large enough for a thumb without covering important UI.
- [x] Keep the regions symmetric unless a documented layout mode changes them.
- [ ] Add a left-handed or mirrored control option only after the default layout works.

**Done when:** a player can reach either flipper comfortably on the smallest supported phone.

### Step 4.2 — Implement press and hold

- [x] On pointer down in the left region, press the left flipper.
- [x] On pointer down in the right region, press the right flipper.
- [x] Keep each flipper pressed for as long as its owning pointer is held.
- [x] On pointer up, release only the flipper owned by that pointer.
- [x] On pointer cancel or focus loss, release the affected flipper safely.
- [x] Do not use a tap-only callback for the held state.

**Done when:** holding either side leaves its flipper upright and releasing returns it to rest.

### Step 4.3 — Support multi-touch

- [x] Track pointer IDs independently for left and right controls.
- [x] Allow both flippers to be held simultaneously.
- [x] Prevent a third pointer from stealing an active flipper.
- [ ] Test left-then-right and right-then-left ordering.
- [ ] Test releasing one side while continuing to hold the other.

**Done when:** both flippers can be activated together without missed releases or stuck flippers.

### Step 4.4 — Tune the flipper physics

- [ ] Define rest angle and raised angle for each flipper.
- [ ] Define motor speed, maximum torque, and return behavior.
- [ ] Confirm the flipper pivot is visually aligned with the sprite.
- [ ] Confirm the ball cannot pass through the flipper at ordinary play speed.
- [ ] Confirm the ball receives a predictable upward kick near the sweet spot.
- [ ] Prevent the ball from becoming trapped between a flipper and guide.
- [ ] Add optional input sound and haptic feedback without coupling them to physics.

**Done when:** 50 controlled shots can be made without a flipper desynchronizing from its sprite or input state.

## 9. Phase 5 — Drain, lives, and turn reset

### Step 5.1 — Add the drain sensor

- [ ] Create a sensor below the lower flippers.
- [ ] Detect only the active ball entering the drain.
- [ ] Debounce duplicate drain callbacks.
- [ ] Stop scoring and collision effects for a draining ball.
- [ ] Animate or fade the ball out only after its state becomes `draining`.

**Done when:** one physical drain produces exactly one ball-lost event.

### Step 5.2 — Add turn management

- [ ] Start each game with the configured number of balls.
- [ ] Decrement the ball count once after a confirmed drain.
- [ ] Spawn the next ball in the launcher after the drain transition.
- [ ] Show a clear ready state before the next launch.
- [ ] Enter game over only after the final ball is lost.
- [ ] Allow restart to reset score, targets, bonuses, and ball state.

**Done when:** a complete three-ball game can be played from start to game over and restarted.

### Step 5.3 — Add ball-save protection

- [ ] Add a configurable ball-save timer after launch.
- [ ] Show the active ball-save state in the HUD.
- [ ] Return a drained ball to the launcher while the timer is active.
- [ ] Consume the save exactly once.
- [ ] Test ball save with drain callbacks, pause, and app backgrounding.

**Done when:** the ball-save feature cannot duplicate balls or extend indefinitely.

## 10. Phase 6 — Bumper system

### Step 6.1 — Create a reusable bumper component

- [x] Define a circular or rounded collision body for a bumper.
- [x] Define the bumper center, radius, impulse strength, and score value.
- [x] Apply a controlled outward impulse on ball contact.
- [x] Add a per-bumper cooldown so one contact cannot score repeatedly in one frame.
- [ ] Emit a typed bumper-hit event.
- [x] Keep the visual animation separate from the collision body.

**Done when:** one bumper reliably bounces the ball and awards one score event per hit.

### Step 6.2 — Produce bumper sprite variants

- [ ] Create a red standard bumper sprite.
- [ ] Create a blue standard bumper sprite.
- [ ] Create an inactive, lit, and hit animation state for each color.
- [ ] Create a small paw-print cap or badge that matches the dog-park theme.
- [ ] Keep silhouettes readable at the logical 360×640 resolution.
- [ ] Export transparent PNGs with nearest-neighbor scaling and no baked text.

**Sprite prompt template:**

> Original 1995 PC pinball pixel-art bumper sprite for a dog-park tennis-ball table, [red or blue] glossy dome, chunky dark navy outline, bright specular pixels, small paw-print details, front orthographic view, transparent background, isolated object, no text, no logo, no modern gradients, crisp hard-edged pixels, designed at 64×64 source pixels and suitable for nearest-neighbor HD scaling.

### Step 6.3 — Expand bumper placement

- [ ] Add named bumper sockets to the table layout rather than hard-coded anonymous positions.
- [x] Place a left and right upper bumper pair.
- [x] Place a central lower bumper with a clear return path.
- [x] Add at least two additional bumper positions in the mid-playfield.
- [ ] Ensure no bumper blocks every route to the flippers.
- [ ] Ensure no bumper overlaps a ramp entrance, sling, target, or launcher lane.
- [ ] Test each placement with debug outlines and a slow-motion mode.

**Done when:** the expanded bumper layout creates varied rebounds without dead zones or unfair drains.

### Step 6.4 — Tune bumper feedback

- [ ] Add a short hit animation.
- [ ] Add a compact impact flash or pixel burst.
- [ ] Add score popup or HUD feedback.
- [ ] Add sound and optional haptic feedback.
- [ ] Test that feedback cannot reduce the physics frame rate.

**Done when:** a bumper hit is readable visually, audibly, and through score change without obscuring the ball.

## 11. Phase 7 — Slingshots

### Step 7.1 — Define slingshot behavior

- [x] Create left and right triangular slingshot collision regions above the flippers.
- [x] Define the active edge and the safe interior edge.
- [x] Apply an angled impulse away from the contact side and upward into play.
- [x] Add a short cooldown per slingshot.
- [x] Award score once per accepted activation.
- [x] Prevent the ball from being repeatedly trapped between a sling and wall.

**Done when:** each sling provides a distinct, controllable kick and does not behave like a full bumper.

### Step 7.2 — Create slingshot sprites

- [x] Create a left-facing dog-park slingshot sprite.
- [x] Create a mirrored right-facing sprite.
- [ ] Create idle, armed, hit, and cooldown frames.
- [x] Add chunky cream rubber, red end caps, navy outlines, and small paw accents.
- [x] Export the mirrored variant from the same source design where possible.

**Sprite prompt template:**

> Original 1995 PC pinball pixel-art slingshot assembly for a dog-themed tennis-ball table, [left/right] triangular rubber kicker, cream rubber band, red end caps, dark navy outline, tiny paw-print accent, three-quarter top-down table view, transparent background, no text, no logo, crisp limited palette, strong silhouette, 96×64 source pixels, nearest-neighbor friendly.

### Step 7.3 — Test lower-playfield routing

- [ ] Fire test shots at both slingshots from multiple approach angles.
- [ ] Verify the left and right slingshots are mirrored in physics and artwork.
- [ ] Verify the drain remains possible but not excessive.
- [ ] Verify the flippers remain the primary recovery tool.
- [ ] Test simultaneous sling activation with multi-ball disabled first.

**Done when:** the lower playfield feels active while still allowing skilled recovery.

## 12. Phase 8 — Ramps

Ramps must be implemented as real routes with a defined entry, travel path, exit, and rule result. A decorative line is not a ramp.

### Step 8.1 — Define ramp contracts

- [ ] Define each ramp ID, entrance region, travel path, exit region, and score.
- [ ] Define whether the ramp is a physical channel, a sensor-guided route, or a controlled transfer.
- [ ] Define whether a ball can enter from both directions.
- [ ] Define the failure behavior when a ball misses the entrance.
- [ ] Define the maximum occupancy and anti-stuck timeout.

**Done when:** every ramp has a one-page behavior specification before art is finalized.

### Step 8.2 — Build the first bone ramp

- [ ] Use placeholder rails and guide colliders.
- [ ] Add an entrance sensor.
- [ ] Guide or constrain the ball through the ramp lane.
- [ ] Add an exit sensor that returns the ball to the playfield.
- [ ] Prevent the ball from escaping through the visual ramp walls.
- [ ] Award the ramp score once per completed traversal.

**Done when:** the first ramp can be entered, traveled, exited, scored, and recovered from repeatedly.

### Step 8.3 — Add unique ramp outcomes

- [ ] Ramp A: award a dog-bone lane score and return the ball to the upper playfield.
- [ ] Ramp B: light one target or advance a target sequence.
- [ ] Ramp C: feed the launcher lane or activate a temporary ball-save state.
- [ ] Show the active outcome in the HUD.
- [ ] Ensure each outcome can be tested independently.

**Done when:** ramps are strategically different, not only visually different.

### Step 8.4 — Create ramp art

- [ ] Create transparent rail, entrance, support, and exit sprites.
- [ ] Create a dog-bone ramp hero sprite with readable highlights.
- [ ] Create lit and unlit ramp states.
- [ ] Keep collision edges aligned with the inner edge of the artwork.
- [ ] Use depth ordering so the ball appears above or below the ramp correctly.

**Sprite prompt template:**

> Original 1995 PC pinball pixel-art dog-bone ramp segment, chunky cream and red rails, dark navy outline, small metal supports, readable entrance and exit, top-down three-quarter pinball table perspective, transparent background, no text, no logo, limited saturated arcade palette, crisp hard-edged pixels, modular tileable parts, 128×96 source pixels.

## 13. Phase 9 — Habitrails and elevated routes

Habitrails are raised guide paths that must communicate depth and provide a unique table function.

### Step 9.1 — Define habitrail routes

- [ ] Choose a clearly visible start and end point for each habitrail.
- [ ] Define the raised route centerline and width.
- [ ] Define support-post positions and depth layers.
- [ ] Define the capture condition and release condition.
- [ ] Define a timeout and escape behavior for an invalid route state.

**Done when:** each habitrail has a route diagram and a tested failure path.

### Step 9.2 — Implement habitrail capture and release

- [ ] Detect the ball entering the capture sensor.
- [ ] Transfer control to the route only after a valid capture.
- [ ] Move or constrain the ball along the route without visual jitter.
- [ ] Release the ball with a defined exit velocity and direction.
- [ ] Prevent a second capture while the route is occupied.
- [ ] Release safely when the app pauses or loses focus.

**Done when:** a ball can travel the route 50 times without becoming stuck or duplicating.

### Step 9.3 — Add unique habitrail functions

- [ ] Doghouse habitrail: award a bonus when the ball completes the doghouse route.
- [ ] Upper return habitrail: send the ball to a new upper-table entry point.
- [ ] Rescue habitrail: return a ball toward the flippers after a difficult shot.
- [ ] Optional multiplier habitrail: increase the score multiplier once per completed route.
- [ ] Add route lighting so the player understands which function is active.

**Done when:** each habitrail changes the player's decision-making and has visible feedback.

### Step 9.4 — Create habitrail art

- [ ] Create transparent rail segments, supports, junctions, and end caps.
- [ ] Create a darker underside or shadow layer to communicate elevation.
- [ ] Create lit route segments for active, completed, and inactive states.
- [ ] Keep the ball readable against both rail and background layers.
- [ ] Verify z-order with the debug ball and final sprite.

**Sprite prompt template:**

> Original 1995 PC pinball pixel-art elevated habitrail section for a dog-park table, silver and cream rail with chunky navy outline, visible support posts and pixel shadow, [straight/curve/junction] modular piece, top-down three-quarter view, transparent background, no text, no logo, crisp limited palette, hard-edged pixels, 128×64 source pixels, designed for seamless assembly.

## 14. Phase 10 — Lower playfield and recovery geometry

- [ ] Define the left and right inlanes.
- [ ] Define the left and right outlanes.
- [ ] Add lane guides that direct the ball toward flippers or drain.
- [ ] Add lane-entry sensors for scoring and lighting.
- [ ] Add optional outlane kickers or a ball-save gate.
- [ ] Confirm the flipper gap is intentional and readable.
- [ ] Add a center drain guide that does not create an invisible dead spot.
- [ ] Test recovery from every lower-playfield entry.

**Done when:** the player understands why a ball drained and can influence most recoverable shots.

## 15. Phase 11 — Background sprite and full visual composition

The background is important, but it comes after collision geometry so the art cannot conceal physics mistakes.

### Step 11.1 — Define background layers

- [ ] Create a base playfield texture with no collision information.
- [ ] Create a darker outer cabinet and rail layer.
- [ ] Create dog-park background details that do not compete with the ball.
- [ ] Create a midground decoration layer for grass, paths, and themed props.
- [ ] Create a foreground trim layer for rails, posts, and overlays.
- [ ] Document which layer is behind the ball, above the ball, or UI-only.

### Step 11.2 — Produce the background sprite

- [ ] Use a source layout aligned to the 360×640 logical canvas.
- [ ] Preserve large quiet areas behind the moving ball.
- [ ] Use a limited 1995-inspired palette with modern HD cleanliness.
- [ ] Avoid tiny high-contrast details near the ball path.
- [ ] Export as modular layers if the single texture becomes too large.
- [ ] Test texture memory on the reference iPhone.

**Sprite prompt template:**

> Original dog-park pinball playfield background in crisp 1995 PC arcade pixel art, portrait table composition, deep green grass field, dark navy cabinet rails, playful doghouse and park details, empty readable lanes for bumpers and ramps, limited saturated palette, chunky pixel clusters, no text, no logo, no copied game elements, no blur, no anti-aliasing, designed as layered transparent-compatible artwork at 360×640 logical composition for nearest-neighbor HD scaling.

### Step 11.3 — Integrate without changing gameplay

- [ ] Place the background beneath all physics-linked sprites.
- [ ] Confirm decorative props have no accidental collision.
- [ ] Confirm the ball remains visible in bright and dark regions.
- [ ] Confirm the launcher, flippers, bumpers, slingshots, ramps, and habitrails remain readable.
- [ ] Compare the final composition to the baseline screenshot.

**Done when:** the complete table looks intentional without changing any physics result.

## 16. Phase 12 — Rules, scoring, and feedback

### Step 12.1 — Centralize scoring

- [ ] Define score values in one rules configuration.
- [ ] Add typed score events for bumper, sling, target, ramp, habitrail, spinner, and bonus hits.
- [ ] Prevent duplicate score events from one collision.
- [ ] Add a score multiplier with a clear maximum.
- [ ] Add a debug score-event history.

Suggested starting values, subject to playtesting:

- Bumper: 100 points
- Slingshot: 50 points
- Target: 250 points
- Ramp completion: 500 points
- Habitrail completion: 750 points
- Mission completion: 5,000 points

### Step 12.2 — Connect existing themed objects

- [ ] Give the fire-hydrant spinner a rotation-based score event.
- [ ] Give the water bowl a timed ball-save or bonus behavior.
- [ ] Give chew toys a readable hit response and score value.
- [ ] Give the doghouse lane a completion condition.
- [ ] Give paw-print targets a sequence or group condition.
- [ ] Reset all object states correctly between balls and games.

**Done when:** every visible interactive object has a rule, score, reset behavior, and test.

### Step 12.3 — Improve HUD communication

- [ ] Show the current score and multiplier without covering the playfield.
- [ ] Show balls remaining and ball-save state.
- [ ] Show ramp, habitrail, target, and mission progress.
- [ ] Show a brief readable message for major events.
- [ ] Ensure score changes are visible even when sound is muted.
- [ ] Verify text remains crisp and readable on small phones.

## 17. Phase 13 — Audio, haptics, and pixel polish

- [ ] Add separate sounds for launch, wall hit, bumper hit, sling hit, ramp, habitrail, drain, and bonus.
- [ ] Add pitch or volume variation without making events confusing.
- [ ] Keep audio event dispatch separate from physics calculations.
- [ ] Add optional haptics for flippers, bumpers, slingshots, and major bonuses.
- [ ] Respect the existing mute and haptic settings.
- [ ] Add hit flashes and pixel particles only after collision behavior is stable.
- [ ] Add a short ball trail only if it does not reduce ball readability.
- [ ] Add screen shake only for major events and clamp it on small devices.
- [ ] Profile particle count and texture memory on iPhone.

**Done when:** presentation improves impact without hiding the ball or changing control timing.

## 18. Phase 14 — Testing plan for every gameplay increment

### 18.1 Unit tests

- [ ] Test plunger pull clamping and impulse calculation.
- [ ] Test pointer ownership and release/cancel behavior.
- [ ] Test simultaneous left/right flipper ownership.
- [ ] Test ball lifecycle transitions.
- [ ] Test drain debouncing.
- [ ] Test life decrement and game-over transitions.
- [ ] Test bumper and sling cooldowns.
- [ ] Test score-event aggregation and multiplier limits.
- [ ] Test ramp and habitrail route timeout behavior.
- [ ] Test reset behavior for every interactive object.

### 18.2 Forge2D and simulation tests

- [ ] Launch a ball at low, medium, and maximum plunger strength.
- [ ] Check that the ball remains within the boundary geometry.
- [ ] Check repeated wall, bumper, and sling contacts.
- [ ] Check flipper interception at multiple approach angles.
- [ ] Check high-speed collision behavior and tunneling prevention.
- [ ] Check ramp entry, travel, exit, and missed-entry behavior.
- [ ] Check habitrail capture, release, and timeout behavior.
- [ ] Run a long simulation with random impulses and verify no stuck state.

### 18.3 Widget and input tests

- [ ] Test portrait layout at narrow, standard, and extra-tall sizes.
- [ ] Test safe-area inset handling.
- [ ] Test HUD buttons do not trigger flippers.
- [ ] Test touch down, hold, up, cancel, and app focus loss.
- [ ] Test both flippers held simultaneously.
- [ ] Test plunger pointer ownership with another pointer active.
- [ ] Test mute and haptic accessibility semantics remain present.

### 18.4 Physical-device matrix

- [ ] Reference iPhone: loading, start, plunger, flippers, drain, restart.
- [ ] Second iPhone size: touch zones, safe areas, readability, performance.
- [ ] Android phone: touch, orientation, audio, haptics, frame pacing.
- [ ] Windows: mouse/keyboard controls, debug overlays, release executable.
- [ ] Low-power or older device: memory, heat, battery, and sustained frame rate.

### 18.5 Manual acceptance script

Run this script on every milestone build:

1. Launch the app and verify the loading screen completes.
2. Start a new game and verify exactly one visible ball is in the launcher.
3. Pull the plunger a little, hold, and verify the sprite follows the finger.
4. Release and verify the ball launches with a proportional impulse.
5. Hold the left side and verify the left flipper remains raised.
6. Hold the right side and verify the right flipper remains raised.
7. Hold both sides and verify both flippers remain raised.
8. Release one side and verify only that flipper returns.
9. Hit a bumper and verify bounce, animation, sound setting, and score.
10. Hit both slingshots and verify distinct angled kicks.
11. Complete each ramp and habitrail route and verify its unique result.
12. Drain the ball and verify exactly one life is removed.
13. Repeat until game over, then restart and verify a clean table.
14. Pause, background the app, resume, and verify no stuck input or duplicate ball.

**Milestone acceptance:** every applicable line passes on iPhone before the related phase is marked complete.

## 19. Phase 15 — Performance and release regression

- [ ] Profile a normal game with all current sprites, audio, particles, and overlays.
- [ ] Profile the busiest moment with multiple effects active.
- [ ] Keep gameplay frame pacing stable during bumper and sling bursts.
- [ ] Confirm no allocations or texture loads occur in the collision hot path.
- [ ] Confirm app pause/resume does not leak physics bodies or pointers.
- [ ] Confirm release builds contain the intended assets and no debug overlay.
- [ ] Run Flutter analyze and the complete automated test suite.
- [ ] Run the iOS unsigned IPA workflow for device testing.
- [ ] Run Android and Windows release validation.
- [ ] Record the final device results in `DEVICE_QA_RUNBOOK.md`.
- [ ] Update `CHANGELOG.md` with the playable-loop milestone.

**Done when:** a clean release candidate passes automated checks and the full physical-device script.

## 20. Definition of a complete playable table

- [ ] The ball is visible, responsive, and reliably launched.
- [ ] Gravity and bounce feel intentional rather than floaty or uncontrollable.
- [ ] Left and right flippers respond to touch down, hold, release, cancel, and multi-touch.
- [ ] The plunger responds proportionally to pull distance.
- [ ] Walls, bumpers, slingshots, ramps, habitrails, and drain have reliable collisions.
- [ ] Ramps and habitrails perform distinct functions that affect play.
- [ ] The player can understand score, balls, bonuses, and major table events.
- [ ] A complete game can end and restart without stale state.
- [ ] The table remains readable in the 1995-inspired pixel style on modern HD phones.
- [ ] The background sprite completes the presentation without obscuring gameplay.
- [ ] iPhone, Android, and Windows behavior has been recorded and accepted.

## 21. Recommended next implementation step

Start with **Step 0.1 — Capture the current baseline**, then immediately implement **Step 1.1 — Define the world coordinate contract**. Once those are recorded, the first code step should be **Step 2.1 — Create the ball model**, because every requested feature depends on seeing and tracking one reliable physics ball.

The first implementation commit should remain narrow: ball body, ball sprite, spawn state, and debug visibility. Do not combine it with final background art, ramps, habitrails, or a large sprite replacement.
