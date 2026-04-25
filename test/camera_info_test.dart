import 'package:flutter_test/flutter_test.dart';
import 'package:camera_info/camera_info.dart';

void main() {
  test('CameraCapabilities can be instantiated', () {
    expect(CameraCapabilities(), isNotNull);
  });

  test('CameraLensCapabilities nullable fields default to null', () {
    const caps = CameraLensCapabilities(
      position: CameraLensPosition.back,
      maxZoomFactor: 1.0,
      minExposureOffset: -2.0,
      maxExposureOffset: 2.0,
    );
    expect(caps.equivalentFocalLength, isNull);
    expect(caps.minZoomFactor, isNull);
    expect(caps.exposureOffsetStepSize, isNull);
  });

  test('CameraLensCapabilities non-nullable fields are set correctly', () {
    const caps = CameraLensCapabilities(
      position: CameraLensPosition.front,
      equivalentFocalLength: 26.0,
      minZoomFactor: 1.0,
      maxZoomFactor: 5.0,
      minExposureOffset: -2.0,
      maxExposureOffset: 2.0,
      exposureOffsetStepSize: 0.5,
    );
    expect(caps.position, CameraLensPosition.front);
    expect(caps.equivalentFocalLength, 26.0);
    expect(caps.minZoomFactor, 1.0);
    expect(caps.maxZoomFactor, 5.0);
    expect(caps.minExposureOffset, -2.0);
    expect(caps.maxExposureOffset, 2.0);
    expect(caps.exposureOffsetStepSize, 0.5);
  });

  test('CameraLensPosition values cover front, back, external', () {
    expect(CameraLensPosition.front.index, 0);
    expect(CameraLensPosition.back.index, 1);
    expect(CameraLensPosition.external.index, 2);
  });
}
