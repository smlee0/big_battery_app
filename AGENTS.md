# Repository Guidelines

## Project Structure & Module Organization
Application code lives in `lib/`, with `lib/main.dart` bootstrapping the UI and delegating to feature widgets as they are added. Widget and integration tests belong in `test/`, mirroring the structure of the code they exercise (e.g., `lib/battery/dashboard.dart` ⇢ `test/battery/dashboard_test.dart`). Mobile- and desktop-specific runners sit under `android/`, `ios/`, `macos/`, `linux/`, `windows/`, and `web/`; treat these as generated artifacts unless you are editing native platform code. Configuration such as dependencies (`pubspec.yaml`) and analyzer rules (`analysis_options.yaml`) is centralized at the repo root.

## Build, Test, and Development Commands
- `flutter pub get` — install or update Dart/Flutter dependencies.
- `flutter run -d chrome` (or another device id) — launch the app locally with hot reload.
- `flutter test` — execute all unit and widget tests in `test/`.
- `flutter analyze` — enforce the lint suite defined in `analysis_options.yaml`.
- `dart format lib test` — apply standard formatting before submitting changes.

## Coding Style & Naming Conventions
Follow the Flutter lints package: 2-space indentation, CamelCase for types, lowerCamelCase for members, and `kConstantCase` only for true compile-time constants. Prefer explicit widget classes over anonymous closures when state management is needed. Run `dart format` and `flutter analyze` before every commit to keep imports ordered and identify lint violations early.

## Testing Guidelines
Add or update tests whenever you touch behavior under `lib/`. Name files with the `_test.dart` suffix and describe behavior in `testWidgets` or `test` blocks using imperative sentences (e.g., `testWidgets('renders battery level')`). Aim to keep widget tests deterministic: mock platform channels and network calls rather than hitting real devices. If you introduce a new feature module, include at least one golden or widget test demonstrating successful rendering plus error handling.

## Commit & Pull Request Guidelines
Write commits in the imperative mood (`feat: add charging indicator`, `fix: correct battery gradient`). Keep commits scoped to a single concern and reference ticket numbers where applicable. Pull requests should summarize the change, list testing evidence (`flutter test`, `flutter analyze`), and include screenshots or screen recordings for UI updates. Request reviews from domain owners of the affected module and ensure CI (if configured) passes before merging.
