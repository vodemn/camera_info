import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera_info/camera_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<CameraLensInfo> _cameras = [];
  String _status = 'Loading...';
  final _plugin = CameraInfo();

  @override
  void initState() {
    super.initState();
    _loadCameraInfo();
  }

  Future<void> _loadCameraInfo() async {
    List<CameraLensInfo> cameras;
    try {
      cameras = await _plugin.getCameraInfo();
    } on PlatformException catch (e) {
      setState(() => _status = 'Error: ${e.message}');
      return;
    }
    if (!mounted) return;
    setState(() {
      _cameras = cameras;
      _status = '${cameras.length} camera(s) found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('camera_info example')),
        body: _cameras.isEmpty
            ? Center(child: Text(_status))
            : ListView.separated(
                itemCount: _cameras.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final cam = _cameras[i];
                  final positionLabel = switch (cam.position) {
                    CameraLensPosition.front    => 'Front',
                    CameraLensPosition.back     => 'Back',
                    CameraLensPosition.external => 'External',
                  };
                  final title = cam.isMain
                      ? '$positionLabel (Main)'
                      : positionLabel;
                  return ListTile(
                    leading: cam.isMain
                        ? const Icon(Icons.star, color: Colors.amber)
                        : const Icon(Icons.camera_alt_outlined),
                    title: Text(title),
                    subtitle: Text(
                      'EFL: ${cam.equivalentFocalLength?.toStringAsFixed(1) ?? 'n/a'} mm\n'
                      'Zoom: ${cam.minZoomFactor?.toStringAsFixed(1) ?? 'n/a'}x – ${cam.maxZoomFactor.toStringAsFixed(1)}x\n'
                      'Exposure: ${cam.minExposureOffset.toStringAsFixed(1)} – ${cam.maxExposureOffset.toStringAsFixed(1)} EV\n'
                      'EV step: ${cam.exposureOffsetStepSize?.toStringAsFixed(2) ?? 'n/a'}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}
