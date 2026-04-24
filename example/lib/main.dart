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
  List<CameraLensCapabilities> _cameras = [];
  String _status = 'Loading...';
  final _plugin = CameraCapabilities();

  @override
  void initState() {
    super.initState();
    _loadCapabilities();
  }

  Future<void> _loadCapabilities() async {
    List<CameraLensCapabilities> cameras;
    try {
      cameras = await _plugin.getCameraCapabilities();
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
                  return ListTile(
                    title: Text('Camera ${i + 1}'),
                    subtitle: Text(
                      'Focal length: ${cam.focalLength?.toStringAsFixed(1) ?? 'n/a'} mm\n'
                      'Aperture: f/${cam.aperture?.toStringAsFixed(1) ?? 'n/a'}\n'
                      'FOV: ${cam.fieldOfView?.toStringAsFixed(1) ?? 'n/a'}°\n'
                      'Zoom: ${cam.minZoomFactor?.toStringAsFixed(1) ?? 'n/a'}x – ${cam.maxZoomFactor?.toStringAsFixed(1) ?? 'n/a'}x\n'
                      'EV step: ${cam.exposureOffsetStepSize ?? 'n/a'}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}
