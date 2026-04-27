import 'package:flutter_test/flutter_test.dart';
import 'package:camera_info/camera_info.dart';

final _iosLens = IosCameraLensInfo(
  position: CameraLensPosition.back,
  equivalentFocalLength: 26.0,
  minZoomFactor: 1.0,
  maxZoomFactor: 6.0,
  minExposureOffset: -8.0,
  maxExposureOffset: 8.0,
  isMain: true,
);

final _androidLens = AndroidCameraLensInfo(
  position: CameraLensPosition.front,
  equivalentFocalLength: 22.0,
  minZoomFactor: 1.0,
  maxZoomFactor: 4.0,
  minExposureOffset: -2.0,
  maxExposureOffset: 2.0,
  exposureOffsetStepSize: 0.5,
  isMain: false,
);

void main() {
  group('CameraLensInfo', () {
    test('nullable fields default to null', () {
      const caps = CameraLensInfo(
        position: CameraLensPosition.back,
        maxZoomFactor: 1.0,
        minExposureOffset: -2.0,
        maxExposureOffset: 2.0,
        isMain: true,
      );
      expect(caps.equivalentFocalLength, isNull);
      expect(caps.minZoomFactor, isNull);
      expect(caps.exposureOffsetStepSize, isNull);
    });

    test('all fields are set correctly', () {
      const caps = CameraLensInfo(
        position: CameraLensPosition.front,
        equivalentFocalLength: 26.0,
        minZoomFactor: 1.0,
        maxZoomFactor: 5.0,
        minExposureOffset: -2.0,
        maxExposureOffset: 2.0,
        exposureOffsetStepSize: 0.5,
        isMain: false,
      );
      expect(caps.position, CameraLensPosition.front);
      expect(caps.equivalentFocalLength, 26.0);
      expect(caps.minZoomFactor, 1.0);
      expect(caps.maxZoomFactor, 5.0);
      expect(caps.minExposureOffset, -2.0);
      expect(caps.maxExposureOffset, 2.0);
      expect(caps.exposureOffsetStepSize, 0.5);
      expect(caps.isMain, isFalse);
    });
  });

  group('CameraLensPosition', () {
    test('index values are stable', () {
      expect(CameraLensPosition.front.index, 0);
      expect(CameraLensPosition.back.index, 1);
      expect(CameraLensPosition.external.index, 2);
    });
  });

  group('CameraInfo caching', () {
    final api = CameraInfo();

    setUp(() => CameraInfo.setMockInitialValues());

    test('getIosCameraInfo returns mock iOS data without a platform call', () async {
      CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
      final result = await api.getIosCameraInfo();
      expect(result, [_iosLens]);
    });

    test('getAndroidCameraInfo returns mock Android data without a platform call', () async {
      CameraInfo.setMockInitialValues(androidInfo: [_androidLens]);
      final result = await api.getAndroidCameraInfo();
      expect(result, [_androidLens]);
    });

    test('getCameraInfo maps mock iOS data to shared model', () async {
      CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
      final result = await api.getCameraInfo();
      expect(result, hasLength(1));
      final lens = result.first;
      expect(lens.position, _iosLens.position);
      expect(lens.equivalentFocalLength, _iosLens.equivalentFocalLength);
      expect(lens.minZoomFactor, _iosLens.minZoomFactor);
      expect(lens.maxZoomFactor, _iosLens.maxZoomFactor);
      expect(lens.minExposureOffset, _iosLens.minExposureOffset);
      expect(lens.maxExposureOffset, _iosLens.maxExposureOffset);
      expect(lens.exposureOffsetStepSize, isNull);
      expect(lens.isMain, _iosLens.isMain);
    });

    test('getCameraInfo maps mock Android data to shared model', () async {
      CameraInfo.setMockInitialValues(androidInfo: [_androidLens]);
      final result = await api.getCameraInfo();
      expect(result, hasLength(1));
      final lens = result.first;
      expect(lens.position, _androidLens.position);
      expect(lens.equivalentFocalLength, _androidLens.equivalentFocalLength);
      expect(lens.minZoomFactor, _androidLens.minZoomFactor);
      expect(lens.maxZoomFactor, _androidLens.maxZoomFactor);
      expect(lens.minExposureOffset, _androidLens.minExposureOffset);
      expect(lens.maxExposureOffset, _androidLens.maxExposureOffset);
      expect(lens.exposureOffsetStepSize, _androidLens.exposureOffsetStepSize);
      expect(lens.isMain, _androidLens.isMain);
    });

    test('getMainCameraInfo returns the lens with isMain == true', () async {
      CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
      final main = await api.getMainCameraInfo();
      expect(main.isMain, isTrue);
    });

    test('getMainCameraInfo falls back to first rear camera when none is main', () async {
      final frontLens = IosCameraLensInfo(
        position: CameraLensPosition.front,
        equivalentFocalLength: 22.0,
        minZoomFactor: 1.0,
        maxZoomFactor: 2.0,
        minExposureOffset: -8.0,
        maxExposureOffset: 8.0,
        isMain: false,
      );
      final backLens = IosCameraLensInfo(
        position: CameraLensPosition.back,
        equivalentFocalLength: 26.0,
        minZoomFactor: 1.0,
        maxZoomFactor: 6.0,
        minExposureOffset: -8.0,
        maxExposureOffset: 8.0,
        isMain: false,
      );
      CameraInfo.setMockInitialValues(iosInfo: [frontLens, backLens]);
      final main = await api.getMainCameraInfo();
      expect(main.position, CameraLensPosition.back);
    });

    test('getMainCameraInfo falls back to first camera when no rear camera exists', () async {
      final frontLens = IosCameraLensInfo(
        position: CameraLensPosition.front,
        equivalentFocalLength: 22.0,
        minZoomFactor: 1.0,
        maxZoomFactor: 2.0,
        minExposureOffset: -8.0,
        maxExposureOffset: 8.0,
        isMain: false,
      );
      CameraInfo.setMockInitialValues(iosInfo: [frontLens]);
      final main = await api.getMainCameraInfo();
      expect(main.position, CameraLensPosition.front);
    });

    test('getCameraInfo result is cached across calls', () async {
      CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
      final first = await api.getCameraInfo();
      final second = await api.getCameraInfo();
      expect(identical(first, second), isTrue);
    });

    group('synchronous getters', () {
      test('iosCameraInfo throws StateError when not initialized', () {
        expect(
          () => api.iosCameraInfo,
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('getIosCameraInfo'),
          )),
        );
      });

      test('androidCameraInfo throws StateError when not initialized', () {
        expect(
          () => api.androidCameraInfo,
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('getAndroidCameraInfo'),
          )),
        );
      });

      test('cameraInfo throws StateError when not initialized', () {
        expect(
          () => api.cameraInfo,
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('getCameraInfo'),
          )),
        );
      });

      test('iosCameraInfo returns cached value after async call', () async {
        CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
        await api.getIosCameraInfo();
        expect(api.iosCameraInfo, [_iosLens]);
      });

      test('androidCameraInfo returns cached value after async call', () async {
        CameraInfo.setMockInitialValues(androidInfo: [_androidLens]);
        await api.getAndroidCameraInfo();
        expect(api.androidCameraInfo, [_androidLens]);
      });

      test('cameraInfo returns cached value after async call', () async {
        CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
        await api.getCameraInfo();
        expect(api.cameraInfo, hasLength(1));
        expect(api.cameraInfo.first.position, _iosLens.position);
      });
    });

    test('setMockInitialValues clears cache when called with no arguments', () async {
      CameraInfo.setMockInitialValues(iosInfo: [_iosLens]);
      await api.getIosCameraInfo(); // populate _iosCache

      CameraInfo.setMockInitialValues(); // clear
      // Without a platform (test host is macOS) and without a mock, the next
      // call must throw — proving the cache was cleared.
      expect(() => api.getIosCameraInfo(), throwsA(isA<UnsupportedError>()));
    });
  });
}
