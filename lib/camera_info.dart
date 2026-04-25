import 'dart:io';

import 'src/camera_info.g.dart';

export 'src/camera_info.g.dart'
    show IosCameraLensCapabilities, AndroidCameraLensCapabilities, CameraLensPosition;

/// Combined cross-platform model.
///
/// Fields that are non-nullable on both platforms are non-nullable here.
/// Fields absent on a platform are null for that platform.
class CameraLensCapabilities {
  const CameraLensCapabilities({
    required this.position,
    required this.maxZoomFactor,
    required this.minExposureOffset,
    required this.maxExposureOffset,
    this.equivalentFocalLength,
    this.minZoomFactor,
    this.exposureOffsetStepSize,
  });

  /// Which side of the device this camera faces. Always present on both platforms.
  final CameraLensPosition position;

  /// 35mm equivalent focal length in mm. Always present on iOS; may be null on Android.
  final double? equivalentFocalLength;

  /// Minimum zoom factor. Always present on iOS; may be null on Android.
  final double? minZoomFactor;

  /// Maximum zoom factor. Always present on both platforms.
  final double maxZoomFactor;

  /// Minimum exposure offset in EV. Always present on both platforms.
  final double minExposureOffset;

  /// Maximum exposure offset in EV. Always present on both platforms.
  final double maxExposureOffset;

  /// Smallest EV step for exposure compensation. Android only; null on iOS.
  final double? exposureOffsetStepSize;
}

/// Provides access to per-camera optical metadata on iOS and Android.
class CameraCapabilities {
  final _iosApi = CameraInfoIosHostApi();
  final _androidApi = CameraInfoAndroidHostApi();

  /// Returns optical capabilities for every camera on iOS.
  ///
  /// All fields are non-nullable — AVFoundation always provides them.
  Future<List<IosCameraLensCapabilities>> get iosCameraCapabilities =>
      _iosApi.getCameraCapabilities();

  /// Returns optical capabilities for every camera on Android.
  ///
  /// Some fields are nullable — see [AndroidCameraLensCapabilities] for details.
  Future<List<AndroidCameraLensCapabilities>> get androidCameraCapabilities =>
      _androidApi.getCameraCapabilities();

  /// Returns optical capabilities for every camera, mapped to the shared
  /// [CameraLensCapabilities] model.
  ///
  /// Use [iosCameraCapabilities] or [androidCameraCapabilities] for full
  /// platform-specific detail with precise nullability.
  Future<List<CameraLensCapabilities>> getCameraCapabilities() async {
    if (Platform.isIOS) {
      return (await iosCameraCapabilities).map(_fromIos).toList();
    } else {
      return (await androidCameraCapabilities).map(_fromAndroid).toList();
    }
  }

  CameraLensCapabilities _fromIos(IosCameraLensCapabilities c) =>
      CameraLensCapabilities(
        position: c.position,
        equivalentFocalLength: c.equivalentFocalLength,
        minZoomFactor: c.minZoomFactor,
        maxZoomFactor: c.maxZoomFactor,
        minExposureOffset: c.minExposureOffset,
        maxExposureOffset: c.maxExposureOffset,
      );

  CameraLensCapabilities _fromAndroid(AndroidCameraLensCapabilities c) =>
      CameraLensCapabilities(
        position: c.position,
        equivalentFocalLength: c.equivalentFocalLength,
        minZoomFactor: c.minZoomFactor,
        maxZoomFactor: c.maxZoomFactor,
        minExposureOffset: c.minExposureOffset,
        maxExposureOffset: c.maxExposureOffset,
        exposureOffsetStepSize: c.exposureOffsetStepSize,
      );
}
