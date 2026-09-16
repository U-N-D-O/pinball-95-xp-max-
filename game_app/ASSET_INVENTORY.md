# Pinball Neo 95 Sprite Inventory

All sprites use the shared HD-source, hard-edged 1995 PC-pinball pixel style. Flutter registers the complete folder through `assets/images/sprites/` in `pubspec.yaml`.

| Asset | Runtime use | Status |
| --- | --- | --- |
| `ball_tennis_idle.png` | Physics-controlled tennis ball | Integrated |
| `bumper_red.png` | Red scoring bumper | Integrated |
| `bumper_blue.png` | Blue scoring bumper | Integrated |
| `doghouse_lane.png` | Doghouse mission landmark | Integrated |
| `paw_mission_target.png` | Three paw mission sensors | Integrated |
| `chew_toy_red_ball.png` | Red chew-toy scorer | Integrated |
| `chew_toy_blue_bone.png` | Blue bone chew-toy scorer | Integrated |
| `chew_toy_rope.png` | Rope chew-toy scorer | Integrated |
| `hydrant_spinner.png` | Rotating hydrant spinner | Integrated |
| `water_bowl.png` | Water-save bonus sensor | Integrated |
| `bone_ramp.png` | Left and right bone ramps | Integrated |
| `launcher_lane.png` | Mobile launch control | Integrated |
| `flipper_left.png` | Left physics flipper | Integrated |
| `flipper_right.png` | Right physics flipper | Integrated |
| `grass_flower_cluster.png` | Four lawn decorations | Integrated |
| `rock_decoration.png` | Four rock decorations | Integrated |
| `paw_decoration.png` | Three lawn paw tracks | Integrated |

The asset-load test checks every file above through Flutter's asset bundle so a path or registration error fails during CI instead of first appearing on a device.
