import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/camera_info.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/vodemn/camera_info/CameraCapabilitiesApi.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.vodemn.camera_info'),
  swiftOut: 'ios/Classes/CameraCapabilitiesApi.g.swift',
  swiftOptions: SwiftOptions(),
))
class CameraLensCapabilities {
  /// Focal length of the lens in millimetres.
  double? focalLength;

  /// Maximum aperture of the lens as an f-number (e.g. 1.8 means f/1.8).
  double? aperture;

  /// Horizontal field of view in degrees.
  double? fieldOfView;

  /// Minimum supported zoom factor (optical + digital).
  double? minZoomFactor;

  /// Maximum supported zoom factor (optical + digital).
  double? maxZoomFactor;

  /// Smallest step by which exposure compensation can be changed (in EV).
  double? exposureOffsetStepSize;
}

@HostApi()
abstract class CameraCapabilitiesHostApi {
  /// Returns optical capabilities for every camera available on the device.
  List<CameraLensCapabilities> getCameraCapabilities();
}
