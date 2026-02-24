# Release Configuration

## Build Mode
**ALWAYS use RELEASE mode for all builds and testing**
- Use `flutter run --release` instead of `flutter run` (for physical devices)
- Use `flutter run --profile` for simulators (Release mode not supported on simulators)
- Use `flutter build --release` instead of `flutter build`
- **Xcode Scheme**: Configured to use Profile mode for LaunchAction (closest to Release for simulators)

## Simulator Limitation
**Important**: Flutter does not support Release mode on iOS simulators. 
- For simulators: Use `--profile` mode (optimized, closest to release)
- For physical devices: Use `--release` mode (fully optimized)

## Demo Account Credentials

**Email:** `demo@flowai.app`  
**Password:** `FlowAiDemo2025!`

This demo account should be used for:
- Testing authentication flows
- App Store/Play Store submissions
- Demo presentations
- User acceptance testing

---

**Last Updated:** December 14, 2025
