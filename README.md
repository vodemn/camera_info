# camera_info

A Flutter plugin that exposes per-camera optical metadata on iOS and Android — information that the standard `camera` plugin does not surface.

## Platform support

| Android | iOS |
|:-------:|:---:|
| ✅      | ✅  |

## Installation

```yaml
dependencies:
  camera_info: ^0.0.1
```

## Usage

### Cross-platform (shared model)

```dart
import 'package:camera_info/camera_info.dart';

final plugin = CameraInfo();
final cameras = await plugin.getCameraInfo();

for (final cam in cameras) {
  print('Position       : ${cam.position.name}');   // front / back / external
  print('Main camera    : ${cam.isMain}');
  print('EFL            : ${cam.equivalentFocalLength} mm');
  print('Zoom range     : ${cam.minZoomFactor}x – ${cam.maxZoomFactor}x');
  print('Exposure range : ${cam.minExposureOffset} – ${cam.maxExposureOffset} EV');
  print('EV step size   : ${cam.exposureOffsetStepSize} EV');
}

// Get the main (wide-angle back) camera
final main = await plugin.getMainCameraInfo();

// Filter to rear cameras only
final rearCameras = cameras
    .where((c) => c.position == CameraLensPosition.back)
    .toList();
```

### Platform-specific (full detail)

```dart
if (Platform.isIOS) {
  final cameras = await plugin.getIosCameraInfo();
  // All fields are non-nullable
  print(cameras.first.equivalentFocalLength);
} else {
  final cameras = await plugin.getAndroidCameraInfo();
  // Some fields are nullable — see AndroidCameraLensInfo
  print(cameras.first.equivalentFocalLength);
}
```

### Synchronous access (after initialization)

```dart
// Await once at startup…
await plugin.getCameraInfo();

// …then access synchronously anywhere
final cameras = plugin.cameraInfo;
final main = plugin.mainCameraInfo;
```

## Data models

### `CameraLensPosition`

```dart
enum CameraLensPosition { front, back, external }
```

| Value | iOS (`AVCaptureDevice.Position`) | Android (`LENS_FACING_*`) |
|---|---|---|
| `front` | `.front` | `LENS_FACING_FRONT` |
| `back` | `.back` | `LENS_FACING_BACK` |
| `external` | anything else | anything else |

### `IosCameraLensInfo`

All fields are non-nullable — AVFoundation always provides them.

| Field | Type | AVFoundation source |
|---|---|---|
| `position` | `CameraLensPosition` | [`AVCaptureDevice.position`](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1387810-position) |
| `isMain` | `bool` | `true` if device matches `AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)` |
| `equivalentFocalLength` | `double` | `18 / tan(videoFieldOfView × π/180 / 2)` via [`AVCaptureDevice.Format.videoFieldOfView`](https://developer.apple.com/documentation/avfoundation/avcapturedevice/format/1624571-videofieldofview) |
| `minZoomFactor` | `double` | [`AVCaptureDevice.minAvailableVideoZoomFactor`](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1622591-minavailablevideozoomfactor) |
| `maxZoomFactor` | `double` | [`AVCaptureDevice.maxAvailableVideoZoomFactor`](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1622425-maxavailablevideozoomfactor) |
| `minExposureOffset` | `double` | [`AVCaptureDevice.minExposureTargetBias`](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624604-minexposuretargetbias) |
| `maxExposureOffset` | `double` | [`AVCaptureDevice.maxExposureTargetBias`](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624601-maxexposuretargetbias) |

### `AndroidCameraLensInfo`

| Field | Type | Camera2 source |
|---|---|---|
| `position` | `CameraLensPosition` | [`LENS_FACING`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#LENS_FACING) |
| `isMain` | `bool` | `true` if camera ID matches the first `LENS_FACING_BACK` entry in `cameraIdList` |
| `equivalentFocalLength` | `double?` | `43.27 × FOCAL_LENGTHS[0] / √(h²+w²)` via [`LENS_INFO_AVAILABLE_FOCAL_LENGTHS`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#LENS_INFO_AVAILABLE_FOCAL_LENGTHS) + [`SENSOR_INFO_PHYSICAL_SIZE`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#SENSOR_INFO_PHYSICAL_SIZE); null if either is absent |
| `minZoomFactor` | `double?` | `1.0` for the main back camera; null for other cameras |
| `maxZoomFactor` | `double` | [`SCALER_AVAILABLE_MAX_DIGITAL_ZOOM`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#SCALER_AVAILABLE_MAX_DIGITAL_ZOOM) |
| `minExposureOffset` | `double` | [`CONTROL_AE_COMPENSATION_RANGE`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#CONTROL_AE_COMPENSATION_RANGE)`.lower × STEP` |
| `maxExposureOffset` | `double` | [`CONTROL_AE_COMPENSATION_RANGE`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#CONTROL_AE_COMPENSATION_RANGE)`.upper × STEP` |
| `exposureOffsetStepSize` | `double` | [`CONTROL_AE_COMPENSATION_STEP`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#CONTROL_AE_COMPENSATION_STEP) |

### `CameraLensInfo` (shared)

Returned by `getCameraInfo()`. Fields are non-nullable only where both platforms guarantee a value.

| Field | Type | Non-null on |
|---|---|---|
| `position` | `CameraLensPosition` | Both |
| `isMain` | `bool` | Both |
| `equivalentFocalLength` | `double?` | iOS only |
| `minZoomFactor` | `double?` | iOS only |
| `maxZoomFactor` | `double` | Both |
| `minExposureOffset` | `double` | Both |
| `maxExposureOffset` | `double` | Both |
| `exposureOffsetStepSize` | `double?` | Android only |

## Development

Platform channels are generated by [Pigeon](https://pub.dev/packages/pigeon). Do not hand-write method channel code.

**Pigeon input:** `pigeons/camera_info.dart`

**Generated files** (committed to git — consumers only need `pub get`):
- `lib/src/camera_info.g.dart`
- `android/src/main/kotlin/com/vodemn/camera_info/CameraInfoApi.g.kt`
- `ios/Classes/CameraInfoApi.g.swift`

To regenerate after editing the pigeons file:

```
fvm flutter pub run pigeon --input pigeons/camera_info.dart
```
