import 'package:flutter_test/flutter_test.dart';
import 'package:camera_info/camera_info.dart';

final _iosLens = IosCameraLensCapabilities(
  position: CameraLensPosition.back,
  equivalentFocalLength: 26.0,
  minZoomFactor: 1.0,
  maxZoomFactor: 6.0,
  minExposureOffset: -8.0,
  maxExposureOffset: 8.0,
);

final _androidLens = AndroidCameraLensCapabilities(
  position: CameraLensPosition.front,
  equivalentFocalLength: 22.0,
  minZoomFactor: 1.0,
  maxZoomFactor: 4.0,
  minExposureOffset: -2.0,
  maxExposureOffset: 2.0,
  exposureOffsetStepSize: 0.5,
);

void main() {
  group('CameraLensCapabilities', () {
    test('nullable fields default to null', () {
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

    test('all fields are set correctly', () {
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
  });

  group('CameraLensPosition', () {
    test('index values are stable', () {
      expect(CameraLensPosition.front.index, 0);
      expect(CameraLensPosition.back.index, 1);
      expect(CameraLensPosition.external.index, 2);
    });
  });

  group('CameraCapabilities caching', () {
    final api = CameraCapabilities();

    setUp(() => CameraCapabilities.setMockInitialValues());

    test('iosCameraCapabilities returns mock iOS data without a platform call', () async {
      CameraCapabilities.setMockInitialValues(iosCapabilities: [_iosLens]);
      final result = await api.iosCameraCapabilities;
      expect(result, [_iosLens]);
    });

    test('androidCameraCapabilities returns mock Android data without a platform call', () async {
      CameraCapabilities.setMockInitialValues(androidCapabilities: [_androidLens]);
      final result = await api.androidCameraCapabilities;
      expect(result, [_androidLens]);
    });

    test('getCameraCapabilities maps mock iOS data to shared model', () async {
      CameraCapabilities.setMockInitialValues(iosCapabilities: [_iosLens]);
      final result = await api.getCameraCapabilities();
      expect(result, hasLength(1));
      final lens = result.first;
      expect(lens.position, _iosLens.position);
      expect(lens.equivalentFocalLength, _iosLens.equivalentFocalLength);
      expect(lens.minZoomFactor, _iosLens.minZoomFactor);
      expect(lens.maxZoomFactor, _iosLens.maxZoomFactor);
      expect(lens.minExposureOffset, _iosLens.minExposureOffset);
      expect(lens.maxExposureOffset, _iosLens.maxExposureOffset);
      expect(lens.exposureOffsetStepSize, isNull);
    });

    test('getCameraCapabilities maps mock Android data to shared model', () async {
      CameraCapabilities.setMockInitialValues(androidCapabilities: [_androidLens]);
      final result = await api.getCameraCapabilities();
      expect(result, hasLength(1));
      final lens = result.first;
      expect(lens.position, _androidLens.position);
      expect(lens.equivalentFocalLength, _androidLens.equivalentFocalLength);
      expect(lens.minZoomFactor, _androidLens.minZoomFactor);
      expect(lens.maxZoomFactor, _androidLens.maxZoomFactor);
      expect(lens.minExposureOffset, _androidLens.minExposureOffset);
      expect(lens.maxExposureOffset, _androidLens.maxExposureOffset);
      expect(lens.exposureOffsetStepSize, _androidLens.exposureOffsetStepSize);
    });

    test('getCameraCapabilities result is cached across calls', () async {
      CameraCapabilities.setMockInitialValues(iosCapabilities: [_iosLens]);
      final first = await api.getCameraCapabilities();
      final second = await api.getCameraCapabilities();
      expect(identical(first, second), isTrue);
    });

    test('setMockInitialValues clears cache when called with no arguments', () async {
      CameraCapabilities.setMockInitialValues(iosCapabilities: [_iosLens]);
      await api.iosCameraCapabilities; // populate _iosCache

      CameraCapabilities.setMockInitialValues(); // clear
      // Without a platform (test host is macOS) and without a mock, the next
      // call must throw — proving the cache was cleared.
      expect(() => api.iosCameraCapabilities, throwsA(isA<UnsupportedError>()));
    });
  });
}
