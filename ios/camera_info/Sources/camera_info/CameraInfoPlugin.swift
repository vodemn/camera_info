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
      let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
      let aspectRatio = getAspectRatio(dimensions: dimensions)
      let equivalentFocalLength = get35mmHorizontalEquivalentFocalLength(format: format)
      let position: CameraLensPosition = switch device.position {
        case .front: .front
        case .back: .back
        default: .external
      }
      return IosCameraLensInfo(
        equivalentFocalLength: equivalentFocalLength,
        equivalentFocalLengthBasis: .horizontal,
        equivalentFocalLengthAspectRatio: aspectRatio,
        minZoomFactor: Double(device.minAvailableVideoZoomFactor),
        maxZoomFactor: Double(device.maxAvailableVideoZoomFactor),
        minExposureOffset: Double(device.minExposureTargetBias),
        maxExposureOffset: Double(device.maxExposureTargetBias),
        position: position,
        isMain: device == mainDevice
      )
    }
  }

  private func get35mmHorizontalEquivalentFocalLength(
    format: AVCaptureDevice.Format
  ) -> Double? {
    let horizontalFovDegrees = Double(format.videoFieldOfView)
    guard horizontalFovDegrees.isFinite, horizontalFovDegrees > 0, horizontalFovDegrees < 180 else {
      return nil
    }

    let horizontalHalfAngleTangent = tan(horizontalFovDegrees * .pi / 360.0)
    guard horizontalHalfAngleTangent.isFinite, horizontalHalfAngleTangent > 0 else { return nil }

    let horizontalEfl = 18.0 / horizontalHalfAngleTangent
    guard horizontalEfl.isFinite, horizontalEfl > 0 else { return nil }
    return horizontalEfl
  }

  private func getAspectRatio(dimensions: CMVideoDimensions) -> Double? {
    guard dimensions.width > 0, dimensions.height > 0 else { return nil }
    let aspectRatio = Double(dimensions.width) / Double(dimensions.height)
    guard aspectRatio.isFinite, aspectRatio > 0 else { return nil }
    return aspectRatio
  }
}
