import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camera_info/camera_info.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getCameraInfo returns a list', (WidgetTester tester) async {
    final plugin = CameraInfo();
    final cameras = await plugin.getCameraInfo();
    expect(cameras, isA<List<CameraLensInfo>>());
    expect(cameras.isNotEmpty, true);
  });
}
