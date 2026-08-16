---
name: EFL basis and geometry contract
overview: "Make each 35mm-equivalent focal-length value self-describing: return its axis convention and the aspect ratio used to derive it, without silently changing conventions."
todos:
  - id: api-contract
    content: Add nullable EFL/aspect fields and the required platform-basis field to Pigeon; regenerate all three bindings.
    status: pending
  - id: ios-native
    content: Compute the active-format aspect; return native horizontal EFL and basis whenever AVFoundation reports a usable horizontal FOV.
    status: pending
  - id: android-native
    content: Return the physical-sensor aspect used by the existing diagonal calculation; reject invalid focal/sensor values and set diagonal basis only with EFL.
    status: pending
  - id: dart-docs-tests
    content: Map and export the contract; update mocks, README, example, changelog, and runnable Dart tests.
    status: pending
  - id: lightmeter-note
    content: Replace the handover with the 0.4.0 Lightmeter migration note and axis-conversion formulas.
    status: pending
isProject: false
---

# EFL basis and geometry contract

## Decisions locked before implementation

- Release as **0.4.0**. This is a breaking API change: iOS `equivalentFocalLength` becomes nullable, and consumers must use the new basis before interpreting a non-null value.
- `equivalentFocalLength` is never silently converted. iOS returns its native horizontal convention; Android returns its diagonal convention derived from physical focal length and sensor size.
- Expose the aspect ratio of the image plane used by the EFL calculation. Name it `equivalentFocalLengthAspectRatio`, rather than `activeFrameAspectRatio`: Android’s current calculation uses `SENSOR_INFO_PHYSICAL_SIZE`, which is not a guarantee about an active preview or capture stream.
- Scope is this package (native API, Dart API, generated bindings, tests, example, README, changelog) plus a short migration note for Lightmeter. Do not change Lightmeter code here.

## Public contract

Add the enum and three nullable fields to both Pigeon platform records and to the shared `CameraLensInfo` model:

| Field | Type | Meaning |
|---|---|---|
| `equivalentFocalLength` | `double?` | The computed 35mm-equivalent focal length in mm. |
| `equivalentFocalLengthBasis` | `EquivalentFocalLengthBasis` | Platform convention: always `horizontal` on iOS and `diagonal` on Android. |
| `equivalentFocalLengthAspectRatio` | `double?` | Landscape `width / height` of the image plane used by the calculation. |

The basis is required even when EFL is null; it identifies the platform's calculation convention, not EFL availability. All non-null EFL and aspect values must be finite and greater than zero. Aspect is independent of EFL: return it when the underlying dimensions are valid even if a focal length/FOV is unavailable. It is not a promise that a preview stream will retain that aspect ratio.

The enum must be exported from `package:camera_info/camera_info.dart` alongside the existing Pigeon record types and `CameraLensPosition`.

## Native behavior

### iOS — `ios/Classes/CameraInfoPlugin.swift`

For every device’s `activeFormat`:

1. Read `CMVideoFormatDescriptionGetDimensions(format.formatDescription)`. If both dimensions are positive, set `equivalentFocalLengthAspectRatio = width / height`.
2. Use the reported horizontal FOV only when it is finite and in the open interval `(0, 180)` degrees.
3. Calculate `horizontalEfl = 18 / tan(horizontalFovDegrees × π / 360)`. Return it only if finite and positive, with `basis: horizontal`.
4. Otherwise return null EFL. Always return `basis: horizontal`; do not calculate a diagonal EFL on iOS.

Make the helper(s) accept the scalar FOV and dimensions, or otherwise extract the calculation sufficiently that edge cases can be tested without an `AVCaptureDevice`.

### Android — `android/src/main/kotlin/com/vodemn/camera_info/CameraInfoPlugin.kt`

1. From `SENSOR_INFO_PHYSICAL_SIZE`, return `equivalentFocalLengthAspectRatio = width / height` only when width and height are finite and positive.
2. Preserve the existing diagonal-equivalent formula, but calculate it only when the first focal length and both sensor dimensions are finite and positive:

   ```text
   efl = √(36² + 24²) × focalLength / √(sensorWidth² + sensorHeight²)
   ```

3. Always return `basis: diagonal`. Return null EFL when it is not finite and positive; the valid sensor aspect may remain populated.
4. Do not add a horizontal fallback on Android.

## API and generated bindings

1. In `pigeons/camera_info.dart`, add `EquivalentFocalLengthBasis { diagonal, horizontal }`. Change iOS `equivalentFocalLength` to `double?`; add required `equivalentFocalLengthBasis` and nullable `equivalentFocalLengthAspectRatio` to both records. Update field documentation to describe the contract above.
2. Regenerate, do not hand-edit, `lib/src/camera_info.g.dart`, `android/src/main/kotlin/com/vodemn/camera_info/CameraInfoApi.g.kt`, and `ios/Classes/CameraInfoApi.g.swift` with:

   ```sh
   fvm flutter pub run pigeon --input pigeons/camera_info.dart
   ```

3. Update `lib/camera_info.dart`: export the enum; add the fields to the `CameraLensInfo` constructor and documentation; map them in `_fromIos` and `_fromAndroid`. Update public comments that currently claim all iOS fields are non-nullable.

## Consumer-facing updates

- Update `test/camera_info_test.dart` fixtures and mapping/default-value assertions for all new fields and the invariant.
- Update `example/lib/main.dart` to display `n/a` for a missing EFL and show its basis and calculation aspect when present.
- Update `README.md` installation to `^0.4.0`, all nullability statements, the platform/shared data tables, and an example that checks EFL and basis together.
- Add an unreleased `0.4.0` breaking-change entry to `CHANGELOG.md`; do not fabricate a release date.
- Replace `camera_info-diagonal-efl-handover.md` with a concise 0.4.0 / Lightmeter migration note. For `a = width / height`:

  ```text
  efl_d = efl_h × √(36²+24²) / (36 × √(1 + 1/a²))
  efl_h = efl_d × 36 × √(1 + 1/a²) / √(36²+24²)
  ```

  Lightmeter first normalizes to its selected axis, then applies its existing medium-/large-format crop conversion. A client deliberately supporting camera_info ≤0.3.x may treat the absent basis as diagonal; a null EFL remains unusable even though 0.4.0+ always supplies a basis.

## Verification and acceptance criteria

- Run Pigeon generation, `dart format` on changed Dart files, `fvm flutter analyze`, and `fvm flutter test`.
- Add runnable Dart tests for shared-model defaults, fixtures, mapping, required basis values, and enum values. The existing test suite has no iOS/Android native test target, so do not claim native helper coverage unless a platform test target is added in this change.
- If native helper tests are introduced, cover: iOS valid horizontal output independent of aspect, zero/out-of-range FOV (null EFL with horizontal basis), and aspect-only output; Android valid diagonal output, invalid/missing focal data (null EFL with diagonal basis), invalid sensor dimensions, and sensor-aspect-only output.
- Inspect the generated Swift/Kotlin/Dart records to confirm constructor argument order and nullable decoding match the Pigeon schema.

## Out of scope

- Preview-tied refreshes and aspect reporting for a selected camera-plugin stream.
- Raw FOV exposure, dual EFL outputs, or an additional Android horizontal calculation.
- Any Lightmeter implementation or repository change.
