import Flutter
import UIKit

public class CameraInfoPlugin: NSObject, FlutterPlugin, CameraCapabilitiesHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CameraInfoPlugin()
    CameraCapabilitiesHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  func getCameraCapabilities() throws -> [CameraLensCapabilities] {
    // TODO: Implement using AVFoundation
    return []
  }
}
