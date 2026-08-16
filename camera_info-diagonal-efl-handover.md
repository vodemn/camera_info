# `camera_info` 0.4.0: Lightmeter EFL migration

`equivalentFocalLength` is now self-describing. Read it together with
`equivalentFocalLengthBasis` and `equivalentFocalLengthAspectRatio`:

- iOS reports `horizontal`, matching AVFoundation's horizontal field-of-view
  metadata.
- Android reports `diagonal`, matching this package's calculation from its
  physical focal length and sensor diagonal.
- The basis is always present, even when EFL is null. A null EFL remains
  unusable; its basis only identifies the platform convention.
- The aspect ratio is the image-plane geometry used by the calculation. On
  iOS it is the active format; on Android it is the physical sensor. It does
  not describe a selected preview stream.

For `a = width / height`, normalize to the user-selected axis before applying
the existing medium- or large-format crop conversion:

```text
efl_d = efl_h × √(36² + 24²) / (36 × √(1 + 1/a²))
efl_h = efl_d × 36 × √(1 + 1/a²) / √(36² + 24²)
```

When deliberately supporting `camera_info` 0.3.x and earlier, the absent new
fields can be treated as `diagonal`, because those releases returned diagonal
EFL on both platforms. This compatibility assumption does not apply when a
0.4.0+ response has a null EFL.
