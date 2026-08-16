# Changelog

## v0.4.0 — Unreleased

### Breaking changes

- Make iOS horizontal equivalent focal length nullable when its horizontal FOV is unusable.
- Add the required `EquivalentFocalLengthBasis` and `equivalentFocalLengthAspectRatio`; iOS reports its native horizontal convention and Android reports its diagonal convention.

## v0.3.0 — 2026-08-11

### Features

- Use diagonal 35mm equivalent focal length on iOS
# Changelog

## v0.2.0 — 2026-04-27

### Features

- Make main camera API non-null with first-camera fallback
# Changelog

## v0.1.0 — 2026-04-26

### Features

- Add capability caching and setMockInitialValues for testing
- Add synchronous capability getters with uninitialized StateError
- Add isMain flag to identify the main camera on each platform

### Miscellaneous

- Add release workflow with automated changelog
- Automate version bump from conventional commits

### Other

- Initial commit

### Refactoring

- Redesign data model with platform-specific types and shared model
- Rename async capability getters to get-prefixed methods
## 0.0.1

- Initial release.
