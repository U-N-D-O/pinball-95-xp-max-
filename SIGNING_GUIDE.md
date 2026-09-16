# Pinball Neo 95 Production Signing Guide

The current release builds intentionally fall back to the local debug key so they can be tested in this workspace. Configure production signing before publishing; never commit a keystore, password, certificate, or private key.

## Android

1. Create or obtain the permanent upload/release keystore through the chosen Play Console ownership account.
2. Copy `game_app/android/key.properties.example` to `game_app/android/key.properties`.
3. Replace every placeholder with the real values. `storeFile` may be an absolute Windows path.
4. Confirm `key.properties` and the keystore remain ignored by `game_app/android/.gitignore`.
5. Run `game_app/tool/build_release.ps1` and verify the AAB with the intended signing workflow.
6. Back up the keystore and recovery information in the organization's secure password/key vault.

When `android/key.properties` exists, the Gradle configuration automatically selects the release signing config. Without it, local release builds continue using the debug key for development only.

## iOS

1. Open `game_app/ios/Runner.xcworkspace` on macOS in Xcode.
2. Set the final Apple Developer Team for the Runner target.
3. Confirm the production bundle identifier is owned by that team.
4. Select the correct Apple Distribution certificate and App Store provisioning profile, preferably with automatic signing managed by the owning team.
5. Archive the Runner target, validate the archive, and upload through the approved App Store Connect account.

## Pre-release checks

- Confirm the signing identity belongs to the intended publisher.
- Test an install/update path using the signed build.
- Keep signing secrets outside source control and CI logs.
- Record certificate and keystore expiry dates in the release calendar.
- Do not treat the locally debug-signed APK or AAB as a store submission artifact.
