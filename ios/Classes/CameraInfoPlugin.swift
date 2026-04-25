import AVFoundation
import Flutter
import UIKit

public class CameraInfoPlugin: NSObject, FlutterPlugin, CameraInfoIosHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CameraInfoPlugin()
    CameraInfoIosHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  func getCameraInfo() throws -> [IosCameraLensInfo] {
    var deviceTypes: [AVCaptureDevice.DeviceType] = [
      .builtInWideAngleCamera,
      .builtInTelephotoCamera,
    ]
    if #available(iOS 13.0, *) {
      deviceTypes.append(.builtInUltraWideCamera)
    }
    let session = AVCaptureDevice.DiscoverySession(
      deviceTypes: deviceTypes,
      mediaType: .video,
      position: .unspecified
    )
    let mainDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    return session.devices.map { device in
      let fovRadians = Double(device.activeFormat.videoFieldOfView) * .pi / 180.0
      let efl = 18.0 / tan(fovRadians / 2.0)
      let position: CameraLensPosition = switch device.position {
        case .front: .front
        case .back: .back
        default: .external
      }
      return IosCameraLensInfo(
        equivalentFocalLength: efl,
        minZoomFactor: Double(device.minAvailableVideoZoomFactor),
        maxZoomFactor: Double(device.maxAvailableVideoZoomFactor),
        minExposureOffset: Double(device.minExposureTargetBias),
        maxExposureOffset: Double(device.maxExposureTargetBias),
        position: position,
        isMain: device == mainDevice
      )
    }
  }
}
