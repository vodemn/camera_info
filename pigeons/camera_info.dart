import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/camera_info.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/vodemn/camera_info/CameraInfoApi.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.vodemn.camera_info'),
  swiftOut: 'ios/Classes/CameraInfoApi.g.swift',
  swiftOptions: SwiftOptions(),
))

/// Which side of the device a camera faces.
enum CameraLensPosition {
  front,
  back,
  external,
}

/// Axis convention used for a 35mm-equivalent focal length.
enum EquivalentFocalLengthBasis {
  diagonal,
  horizontal,
}

class IosCameraLensInfo {
  /// Horizontal 35mm-equivalent focal length, or null when its horizontal FOV is unusable.
  double? equivalentFocalLength;

  /// Axis convention for this platform's EFL calculation: always horizontal on iOS.
  late EquivalentFocalLengthBasis equivalentFocalLengthBasis;

  /// Width / height of the active format used to convert this EFL to another axis.
  double? equivalentFocalLengthAspectRatio;

  /// Minimum zoom factor. AVCaptureDevice.minAvailableVideoZoomFactor.
  late double minZoomFactor;

  /// Maximum zoom factor. AVCaptureDevice.maxAvailableVideoZoomFactor.
  late double maxZoomFactor;

  /// Minimum exposure offset in EV. AVCaptureDevice.minExposureTargetBias.
  late double minExposureOffset;

  /// Maximum exposure offset in EV. AVCaptureDevice.maxExposureTargetBias.
  late double maxExposureOffset;

  /// Which side of the device this camera faces. AVCaptureDevice.position.
  late CameraLensPosition position;

  /// True if this is the main (wide-angle back) camera. AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back).
  late bool isMain;
}

class AndroidCameraLensInfo {
  /// 35mm equivalent focal length. Null if LENS_INFO_AVAILABLE_FOCAL_LENGTHS or SENSOR_INFO_PHYSICAL_SIZE is unavailable.
  double? equivalentFocalLength;

  /// Axis convention for this platform's EFL calculation: always diagonal on Android.
  late EquivalentFocalLengthBasis equivalentFocalLengthBasis;

  /// Width / height of the physical sensor used for EFL geometry, when available.
  double? equivalentFocalLengthAspectRatio;

  /// Minimum zoom factor. 1.0 for the main back camera; null for other cameras.
  double? minZoomFactor;

  /// Maximum zoom factor. CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM.
  late double maxZoomFactor;

  /// Minimum exposure offset in EV. CONTROL_AE_COMPENSATION_RANGE.lower × CONTROL_AE_COMPENSATION_STEP.
  late double minExposureOffset;

  /// Maximum exposure offset in EV. CONTROL_AE_COMPENSATION_RANGE.upper × CONTROL_AE_COMPENSATION_STEP.
  late double maxExposureOffset;

  /// Smallest EV step for exposure compensation. CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP.
  late double exposureOffsetStepSize;

  /// Which side of the device this camera faces. CameraCharacteristics.LENS_FACING.
  late CameraLensPosition position;

  /// True if this is the main (first back-facing) camera. Camera ID matches the first LENS_FACING_BACK camera in cameraIdList.
  late bool isMain;
}

@HostApi()
abstract class CameraInfoIosHostApi {
  /// Returns optical info for every camera available on the device (iOS).
  List<IosCameraLensInfo> getCameraInfo();
}

@HostApi()
abstract class CameraInfoAndroidHostApi {
  /// Returns optical info for every camera available on the device (Android).
  List<AndroidCameraLensInfo> getCameraInfo();
}
