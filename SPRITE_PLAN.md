# Pinball Neo 95 — Sprite and Art Plan

## Art Direction

The game should feel like a 1995 pinball game rebuilt for modern HD phones:

- HD display with deliberately pixelated artwork
- Chunky pixel clusters and crisp hard edges
- Limited arcade color palette
- Strong dark outlines
- Dithered shadows and highlights
- Bright lights and readable silhouettes
- Original dog-park designs
- No photorealistic rendering
- No smooth vector appearance
- No copied assets or recognizable layouts from existing games

## Pixel Rules

- Design for the 360x640 logical game canvas
- Use nearest-neighbor scaling in the game
- Keep important details large enough to read on a phone
- Avoid thin lines and details smaller than two logical pixels
- Keep sprites centered and fully visible
- Use transparent backgrounds for gameplay objects
- Keep lighting direction consistent across the entire table

## Phase 1 — Style Bible

Generate a single reference sheet containing:

- Tennis ball
- Paw bumper
- Bone flipper
- Launcher and plunger
- Doghouse entrance
- Fire hydrant spinner
- Tennis-ball target
- Chew toy
- Dog mascot

Approve the shared pixel density, outline thickness, palette, shading, and proportions before producing the full asset set.

## Phase 2 — Core Gameplay Sprites

Produce individual transparent sprites in this order:

1. Tennis ball
2. Left flipper
3. Right flipper
4. Paw bumpers
5. Launcher and plunger
6. Tennis-ball targets
7. Bone ramps
8. Doghouse lane entrance
9. Fire hydrant spinner
10. Drain and ball-save indicators

## Phase 3 — Table Environment

Create:

- Grass, dirt, and stone tiles
- Water stream and water bowl
- Fences and gates
- Flowers and leaves
- Doghouse walls and roof
- Bone decorations
- Paw-print paths
- Dog characters
- Chew ropes, balls, bones, and toys
- Background lamps and sign elements

## Phase 4 — Animation Frames

Create matching animation frames for:

- Flippers down and raised
- Bumper idle, hit, and cooldown
- Targets off, lit, and completed
- Plunger released and pulled back
- Hydrant spinner rotation
- Water-bowl activation
- Tennis-ball launch and impact
- Ball drain
- Mission completion
- Multiball activation

Each frame must preserve the same shape, camera angle, palette, outline, and pixel density. Only the requested pose or lighting state should change.

## Phase 5 — Interface Art

Create:

- Bitmap-style score font
- Score panel
- Ball counter icons
- Mission indicators
- Bonus multiplier display
- Pause and restart buttons
- Touch-control indicators
- Main menu buttons
- Game-over and high-score panels

## Standard Image Prompt

```text
Use case: stylized-concept
Asset type: 2D mobile pinball game sprite
Primary request: an original [OBJECT] for Pinball Neo 95
Scene/backdrop: genuinely transparent background
Subject: one centered [OBJECT], fully visible and isolated
Style/medium: HD pixel art inspired by mid-1990s PC arcade pinball, chunky pixel clusters, crisp hard edges, limited palette, hand-pixelled shading, strong dark outlines, readable at small size
Composition/framing: centered, no cropping, clear gameplay silhouette
Lighting/mood: bright arcade highlights and warm nostalgic lighting
Color palette: forest green, deep navy, cream, red, blue, golden yellow, and tennis-ball neon yellow
Constraints: original design, no logos, no text, no watermark, no extra objects, no photorealism, no smooth vector art, no blurry anti-aliased edges
```

## Asset Naming

Use predictable names:

```text
ball_tennis_idle.png
ball_tennis_launch.png
bumper_paw_red_idle.png
bumper_paw_red_hit.png
flipper_left_down.png
flipper_left_up.png
target_tennis_lit.png
hydrant_spinner_frame_01.png
```

## Art Approval Checklist

- Matches the style bible
- Has a clear silhouette at gameplay size
- Has transparent edges
- Uses the approved palette
- Has no accidental text or watermark
- Looks consistent beside existing sprites
- Remains readable on a phone screen
