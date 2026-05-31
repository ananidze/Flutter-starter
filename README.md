# Flutter Starter

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A production-ready Flutter starter template with authentication, onboarding, settings, routing, localization, analytics, and a modular package architecture — built with [Very Good CLI][very_good_cli_link].

---

## Features

- **Authentication** — sign in / sign up / magic email link, with Apple and Google OAuth buttons
- **Onboarding** — multi-slide onboarding flow with page indicator
- **Profile** — user card, account deletion dialog
- **Settings** — theme mode toggle, locale selector
- **Force Update** — version gate that redirects users to the store when an update is required
- **Counter** — example feature demonstrating the Cubit pattern
- **Deep Linking** — handled via `app_links`
- **Routing** — declarative navigation with `go_router`
- **State management** — `flutter_bloc` / Cubit pattern throughout
- **Localization** — English and Spanish (ARB-based, extendable)
- **3 flavors** — development / staging / production

---

## Project Structure

```
flutter_starter/
├── lib/
│   ├── app/                  # App widget, router, config
│   ├── bootstrap.dart        # App initialization
│   ├── features/
│   │   ├── auth/             # Sign in, sign up, email link
│   │   ├── counter/          # Example feature
│   │   ├── force_update/     # Version gate
│   │   ├── onboarding/       # Onboarding slides
│   │   ├── profile/          # User profile
│   │   └── settings/         # Theme & locale settings
│   └── l10n/                 # Localization (ARB + generated)
└── packages/
    ├── analytics_client/     # Abstract analytics + Firebase & PostHog impls
    ├── api_client/           # Dio HTTP client (auth, 401, logging interceptors)
    ├── app_ui/               # Shared UI components and theme
    ├── authentication_client/# Auth abstraction + token storage
    ├── feature_flags_client/ # Feature flags + Firebase Remote Config impl
    ├── form_inputs/          # Validated form inputs (email, password, name)
    ├── notifications_client/ # Push notifications + Firebase & OneSignal impls
    └── storage/              # Storage abstraction, persistent & secure impls
```

---

## Getting Started

### Prerequisites

- Flutter `^3.41.0` / Dart `^3.11.0`
- [Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli): `dart pub global activate very_good_cli`

### Run

```sh
# Development
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

_Flutter Starter targets iOS, Android, Web, and Windows._

---

## Running Tests

```sh
very_good test --coverage --test-randomize-ordering-seed random
```

Generate and view the coverage report:

```sh
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

---

## Linting

This project uses [bloc_lint](https://pub.dev/packages/bloc_lint) to enforce Bloc best practices.

```sh
dart run bloc_tools:bloc lint .
```

You can also use the [official Bloc VSCode extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) for inline linting. See [bloclibrary.dev/lint](https://bloclibrary.dev/lint/) for more.

---

## Working with Translations

Translations live in `lib/l10n/arb/`. The project currently supports **English** (`app_en.arb`) and **Spanish** (`app_es.arb`).

### Adding a String

1. Add the key to `lib/l10n/arb/app_en.arb`:

```arb
{
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World greeting."
    }
}
```

2. Use it in a widget:

```dart
import 'package:flutter_starter/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  return Text(context.l10n.helloWorld);
}
```

### Adding a New Locale

1. Add a new ARB file: `lib/l10n/arb/app_<locale>.arb`
2. Register the locale in `ios/Runner/Info.plist`:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>es</string>
    <string>fr</string>
</array>
```

### Generating Translations

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Or just run `flutter run` — code generation runs automatically.

---

## CI

GitHub Actions workflows are in [.github/workflows/](.github/workflows/):

- `main.yaml` — runs analysis, tests, and coverage on every push/PR
- `license_check.yaml` — verifies license headers across the codebase

[coverage_badge]: coverage_badge.svg
[internationalization_link]: https://docs.flutter.dev/ui/internationalization
[arb_documentation_link]: https://github.com/google/app-resource-bundle
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
