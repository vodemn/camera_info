import 'dart:io';

import 'src/camera_info.g.dart';

export 'src/camera_info.g.dart'
    show IosCameraLensInfo, AndroidCameraLensInfo, CameraLensPosition;

/// Combined cross-platform model.
///
/// Fields that are non-nullable on both platforms are non-nullable here.
/// Fields absent on a platform are null for that platform.
class CameraLensInfo {
  const CameraLensInfo({
    required this.position,
    required this.maxZoomFactor,
    required this.minExposureOffset,
    required this.maxExposureOffset,
    required this.isMain,
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

  /// True if this is the main (wide-angle back) camera.
  final bool isMain;
}

/// Provides access to per-camera optical metadata on iOS and Android.
class CameraInfo {
  final _iosApi = CameraInfoIosHostApi();
  final _androidApi = CameraInfoAndroidHostApi();

  static List<IosCameraLensInfo>? _iosCache;
  static List<AndroidCameraLensInfo>? _androidCache;
  static List<CameraLensInfo>? _sharedCache;

  /// Returns optical info for every camera on iOS.
  ///
  /// All fields are non-nullable — AVFoundation always provides them.
  Future<List<IosCameraLensInfo>> getIosCameraInfo() async {
    if (_iosCache != null) return _iosCache!;
    if (!Platform.isIOS) {
      throw UnsupportedError('iOS camera info is not available on this platform');
    }
    return _iosCache ??= await _iosApi.getCameraInfo();
  }

  /// Returns optical info for every camera on Android.
  ///
  /// Some fields are nullable — see [AndroidCameraLensInfo] for details.
  Future<List<AndroidCameraLensInfo>> getAndroidCameraInfo() async {
    if (_androidCache != null) return _androidCache!;
    if (!Platform.isAndroid) {
      throw UnsupportedError('Android camera info is not available on this platform');
    }
    return _androidCache ??= await _androidApi.getCameraInfo();
  }

  /// Synchronously returns the cached iOS camera info.
  ///
  /// Throws [StateError] if [getIosCameraInfo] has not been awaited yet.
  List<IosCameraLensInfo> get iosCameraInfo {
    if (_iosCache == null) {
      throw StateError(
        'iOS camera info is not initialized. '
        'Await getIosCameraInfo before calling iosCameraInfo.',
      );
    }
    return _iosCache!;
  }

  /// Synchronously returns the cached Android camera info.
  ///
  /// Throws [StateError] if [getAndroidCameraInfo] has not been awaited yet.
  List<AndroidCameraLensInfo> get androidCameraInfo {
    if (_androidCache == null) {
      throw StateError(
        'Android camera info is not initialized. '
        'Await getAndroidCameraInfo before calling androidCameraInfo.',
      );
    }
    return _androidCache!;
  }

  /// Synchronously returns the cached shared camera info.
  ///
  /// Throws [StateError] if [getCameraInfo] has not been awaited yet.
  List<CameraLensInfo> get cameraInfo {
    if (_sharedCache == null) {
      throw StateError(
        'Camera info is not initialized. '
        'Await getCameraInfo before calling cameraInfo.',
      );
    }
    return _sharedCache!;
  }

  /// Returns info for the main (wide-angle back) camera.
  ///
  /// Falls back to the first rear-facing camera, or the first camera overall
  /// if no rear camera exists.
  Future<CameraLensInfo> getMainCameraInfo() async {
    final cameras = await getCameraInfo();
    return _resolveMainCamera(cameras);
  }

  /// Synchronously returns the cached main camera info.
  ///
  /// Falls back to the first rear-facing camera, or the first camera overall
  /// if no rear camera exists.
  /// Throws [StateError] if [getCameraInfo] has not been awaited yet.
  CameraLensInfo get mainCameraInfo => _resolveMainCamera(cameraInfo);

  CameraLensInfo _resolveMainCamera(List<CameraLensInfo> cameras) {
    return cameras.firstWhere((c) => c.isMain, orElse: () {
      return cameras.firstWhere(
        (c) => c.position == CameraLensPosition.back,
        orElse: () => cameras.first,
      );
    });
  }

  /// Returns optical info for every camera, mapped to the shared
  /// [CameraLensInfo] model.
  ///
  /// Use [getIosCameraInfo] or [getAndroidCameraInfo] for full
  /// platform-specific detail with precise nullability.
  Future<List<CameraLensInfo>> getCameraInfo() async {
    if (_sharedCache != null) return _sharedCache!;
    if (_iosCache != null || Platform.isIOS) {
      _sharedCache = (await getIosCameraInfo()).map(_fromIos).toList();
    } else if (_androidCache != null || Platform.isAndroid) {
      _sharedCache = (await getAndroidCameraInfo()).map(_fromAndroid).toList();
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
    List<IosCameraLensInfo>? iosInfo,
    List<AndroidCameraLensInfo>? androidInfo,
  }) {
    assert(
      iosInfo != null || androidInfo != null,
      'At least one of the cached values must be provided.',
    );
    _iosCache = iosInfo;
    _androidCache = androidInfo;
  }

  CameraLensInfo _fromIos(IosCameraLensInfo c) => CameraLensInfo(
        position: c.position,
        equivalentFocalLength: c.equivalentFocalLength,
        minZoomFactor: c.minZoomFactor,
        maxZoomFactor: c.maxZoomFactor,
        minExposureOffset: c.minExposureOffset,
        maxExposureOffset: c.maxExposureOffset,
        isMain: c.isMain,
      );

  CameraLensInfo _fromAndroid(AndroidCameraLensInfo c) => CameraLensInfo(
        position: c.position,
        equivalentFocalLength: c.equivalentFocalLength,
        minZoomFactor: c.minZoomFactor,
        maxZoomFactor: c.maxZoomFactor,
        minExposureOffset: c.minExposureOffset,
        maxExposureOffset: c.maxExposureOffset,
        exposureOffsetStepSize: c.exposureOffsetStepSize,
        isMain: c.isMain,
      );
}
