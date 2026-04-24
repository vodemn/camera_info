package com.vodemn.camera_info

import io.flutter.embedding.engine.plugins.FlutterPlugin

class CameraInfoPlugin : FlutterPlugin, CameraCapabilitiesHostApi {
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    CameraCapabilitiesHostApi.setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    CameraCapabilitiesHostApi.setUp(binding.binaryMessenger, null)
  }

  override fun getCameraCapabilities(): List<CameraLensCapabilities> {
    // TODO: Implement using Camera2 API
    return emptyList()
  }
}
