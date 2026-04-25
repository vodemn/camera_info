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

  static List<IosCameraLensCapabilities>? _iosCache;
  static List<AndroidCameraLensCapabilities>? _androidCache;
  static List<CameraLensCapabilities>? _sharedCache;

  /// Returns optical capabilities for every camera on iOS.
  ///
  /// All fields are non-nullable — AVFoundation always provides them.
  Future<List<IosCameraLensCapabilities>> get iosCameraCapabilities async {
    if (_iosCache != null) return _iosCache!;
    if (!Platform.isIOS) {
      throw UnsupportedError('iOS capabilities are not available on this platform');
    }
    return _iosCache ??= await _iosApi.getCameraCapabilities();
  }

  /// Returns optical capabilities for every camera on Android.
  ///
  /// Some fields are nullable — see [AndroidCameraLensCapabilities] for details.
  Future<List<AndroidCameraLensCapabilities>> get androidCameraCapabilities async {
    if (_androidCache != null) return _androidCache!;
    if (!Platform.isAndroid) {
      throw UnsupportedError('Android capabilities are not available on this platform');
    }
    return _androidCache ??= await _androidApi.getCameraCapabilities();
  }

  /// Returns optical capabilities for every camera, mapped to the shared
  /// [CameraLensCapabilities] model.
  ///
  /// Use [iosCameraCapabilities] or [androidCameraCapabilities] for full
  /// platform-specific detail with precise nullability.
  Future<List<CameraLensCapabilities>> getCameraCapabilities() async {
    if (_sharedCache != null) return _sharedCache!;
    if (_iosCache != null || Platform.isIOS) {
      _sharedCache = (await iosCameraCapabilities).map(_fromIos).toList();
    } else if (_androidCache != null || Platform.isAndroid) {
      _sharedCache = (await androidCameraCapabilities).map(_fromAndroid).toList();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    return _sharedCache!;
  }

  /// Overrides the cached values returned by this class.
  ///
  /// Intended for use in tests. Pass null for any cache you want to leave
  /// unset (it will be fetched from the platform on the next call).
  static void setMockInitialValues({
    List<IosCameraLensCapabilities>? iosCapabilities,
    List<AndroidCameraLensCapabilities>? androidCapabilities,
  }) {
    assert(
      iosCapabilities != null || androidCapabilities != null,
      'At least one of the cached capabilities must be provided.',
    );
    _iosCache = iosCapabilities;
    _androidCache = androidCapabilities;
  }

  CameraLensCapabilities _fromIos(IosCameraLensCapabilities c) => CameraLensCapabilities(
        position: c.position,
        equivalentFocalLength: c.equivalentFocalLength,
        minZoomFactor: c.minZoomFactor,
        maxZoomFactor: c.maxZoomFactor,
        minExposureOffset: c.minExposureOffset,
        maxExposureOffset: c.maxExposureOffset,
      );

  CameraLensCapabilities _fromAndroid(AndroidCameraLensCapabilities c) => CameraLensCapabilities(
        position: c.position,
        equivalentFocalLength: c.equivalentFocalLength,
        minZoomFactor: c.minZoomFactor,
        maxZoomFactor: c.maxZoomFactor,
        minExposureOffset: c.minExposureOffset,
        maxExposureOffset: c.maxExposureOffset,
        exposureOffsetStepSize: c.exposureOffsetStepSize,
      );
}
