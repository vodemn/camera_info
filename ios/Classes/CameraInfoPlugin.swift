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
      let format = device.activeFormat
      let efl = get35mmDiagonalEquivalentFocalLength(format: format)
        ?? get35mmHorizontalEquivalentFocalLength(format: format)
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

  private func get35mmDiagonalEquivalentFocalLength(
    format: AVCaptureDevice.Format
  ) -> Double? {
    let horizontalFovDegrees = Double(format.videoFieldOfView)
    guard horizontalFovDegrees > 0 else { return nil }

    let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
    guard dimensions.width > 0, dimensions.height > 0 else { return nil }

    let aspectRatio = Double(dimensions.width) / Double(dimensions.height)
    let horizontalHalfAngleTangent = tan(horizontalFovDegrees * .pi / 360.0)
    let diagonalHalfAngleTangent =
      horizontalHalfAngleTangent * sqrt(1.0 + 1.0 / (aspectRatio * aspectRatio))
    guard diagonalHalfAngleTangent.isFinite, diagonalHalfAngleTangent > 0 else { return nil }

    let fullFrameDiagonal = sqrt(36.0 * 36.0 + 24.0 * 24.0)
    return (fullFrameDiagonal / 2.0) / diagonalHalfAngleTangent
  }

  private func get35mmHorizontalEquivalentFocalLength(
    format: AVCaptureDevice.Format
  ) -> Double {
    let fovRadians = Double(format.videoFieldOfView) * .pi / 180.0
    return 18.0 / tan(fovRadians / 2.0)
  }
}
