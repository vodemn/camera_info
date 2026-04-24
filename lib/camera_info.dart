import 'src/camera_info.g.dart';

export 'src/camera_info.g.dart' show CameraLensCapabilities;

/// Provides access to per-camera optical metadata on iOS and Android.
class CameraCapabilities {
  final _api = CameraCapabilitiesHostApi();

  /// Returns optical capabilities for every camera available on the device.
  ///
  /// Each [CameraLensCapabilities] entry corresponds to one physical camera.
  /// Fields are nullable — not all platforms expose every value.
  Future<List<CameraLensCapabilities>> getCameraCapabilities() =>
      _api.getCameraCapabilities();
}
