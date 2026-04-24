import 'package:flutter_test/flutter_test.dart';
import 'package:camera_info/camera_info.dart';

void main() {
  test('CameraCapabilities can be instantiated', () {
    expect(CameraCapabilities(), isNotNull);
  });

  test('CameraLensCapabilities fields default to null', () {
    final caps = CameraLensCapabilities();
    expect(caps.focalLength, isNull);
    expect(caps.aperture, isNull);
    expect(caps.fieldOfView, isNull);
    expect(caps.minZoomFactor, isNull);
    expect(caps.maxZoomFactor, isNull);
    expect(caps.exposureOffsetStepSize, isNull);
  });
}
