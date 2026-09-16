# Pinball Neo 95 Asset Register

This register records the origin and release status of the assets currently shipped by the Flutter project.

## Project-owned generated assets

| Asset set | Location | Origin | Current status |
| --- | --- | --- | --- |
| Pixel-art table sprites | `game_app/assets/images/sprites/` | Generated specifically for Pinball Neo 95 with the project sprite prompts, then integrated and tested locally. | No external source files identified. Keep the generation record with the project. |
| App icon | `game_app/assets/images/app_icon.png` and platform icon folders | Generated specifically for Pinball Neo 95 with a pixel-art dog-and-pinball prompt, then resized with nearest-neighbor scaling for each platform. | No third-party logos, characters, or text included. |
| Sound effects | `game_app/assets/audio/sfx/` | Generated offline by `game_app/tool/generate_sound_assets.dart` using synthesized waveforms; no sampled recordings are included. | No external audio files identified. Final mix review remains pending. |

## Third-party runtime dependencies

The application uses Flutter, Flame, Forge2D, Flame Audio, Shared Preferences, and their transitive packages. Their licenses belong to their respective authors and are resolved through the package manager. The generated Flutter dependency notice report is archived at `release_legal/THIRD_PARTY_NOTICES.txt`, with its checksum and regeneration instructions in `release_legal/DEPENDENCY_LICENSE_MANIFEST.txt`.

Run `game_app/tool/archive_dependency_notices.ps1` after a Flutter build to refresh the archive. The repeatable release pipeline runs this step automatically before auditing the release artifacts.

## Release review remaining

- Confirm the terms applicable to the generated artwork and icon for the intended distribution channel.
- Keep the generated Flutter dependency license archive alongside each release.
- Replace or approve the current synthesized sound mix as the final release mix.
- Do not add fonts, music, samples, logos, or promotional images without recording their source and license here.
