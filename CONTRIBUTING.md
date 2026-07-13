# Contributing to Flow Ai

Thank you for your interest in Flow Ai.

Flow Ai is proprietary software owned by ZyraFlow GmbH™. Public visibility of
this repository does not grant permission to use, modify, or distribute its
contents.

## Contribution Policy

External contributions require prior written approval from the maintainers.
Please do not submit unsolicited product code, architecture changes, or
proprietary materials.

Report security vulnerabilities privately according to [SECURITY.md](SECURITY.md).

## Development Setup

Requirements:

- Flutter stable
- Dart SDK provided by Flutter
- Xcode for iOS development
- Android Studio and Android SDK for Android development

Install dependencies with `make bootstrap`.

Run the application with `flutter run`.

## Quality Checks

Run `make ci` before opening an approved pull request.
Run `make secrets` to scan for committed secrets.

## Branches and Commits

- Work on a dedicated branch.
- Keep commits atomic and focused.
- Do not mix unrelated changes.
- Use Conventional Commit-style messages where practical.
- Do not alter release code without a verified requirement.
- Never commit credentials, signing assets, or private user data.

## Pull Requests

Approved pull requests must explain the change, describe testing performed,
identify relevant risks, include only related files, and pass required checks.

All contributions are subject to review and may be declined at the sole
discretion of ZyraFlow GmbH™.
