# Unsigned iOS test build

The repository contains a manual GitHub Actions workflow for producing an unsigned iOS test IPA:

`.github/workflows/ios-unsigned-ipa.yml`

## Run it

1. Open the repository on GitHub.
2. Open **Actions** and select **iOS unsigned test IPA**.
3. Choose **Run workflow** and keep the pinned Flutter version (`3.47.4`) unless the project is intentionally upgraded.
4. Download the `pinball-neo-95-ios-unsigned` artifact from the completed workflow run.
5. Verify the IPA with the included `.sha256` file before moving it to a test device.

The workflow runs `flutter analyze` and `flutter test`, builds with `flutter build ios --release --no-codesign`, and packages `build/ios/iphoneos/Runner.app` as `Payload/Runner.app` inside the IPA.

## Important limitations

- An unsigned IPA is for development and inspection only. It is not an App Store submission artifact.
- Installing it on a physical iPhone still requires a compatible signing/install process, such as Xcode signing with a development team or an authorized device-testing service.
- Production distribution remains blocked until the Apple Developer team, certificates, and provisioning profile are configured on macOS.
- The workflow is manual by design so every test IPA build is intentional and the artifact does not get regenerated on every push.
