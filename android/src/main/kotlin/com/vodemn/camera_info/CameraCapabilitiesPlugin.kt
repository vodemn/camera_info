package com.vodemn.camera_info

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlin.math.pow
import kotlin.math.sqrt

class CameraInfoPlugin : FlutterPlugin, CameraInfoAndroidHostApi {
  private lateinit var cameraManager: CameraManager

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    cameraManager = binding.applicationContext.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    CameraInfoAndroidHostApi.setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    CameraInfoAndroidHostApi.setUp(binding.binaryMessenger, null)
  }

  override fun getCameraCapabilities(): List<AndroidCameraLensCapabilities> {
    val ids = cameraManager.cameraIdList
    val mainBackId = ids.firstOrNull { id ->
      cameraManager.getCameraCharacteristics(id)
        .get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_BACK
    }
    return ids.map { id ->
      val c = cameraManager.getCameraCharacteristics(id)
      val focalLength = c.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)?.firstOrNull()
      val sensorSize = c.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)
      val efl = if (focalLength != null && sensorSize != null) {
        43.27 * focalLength / sqrt(sensorSize.height.pow(2) + sensorSize.width.pow(2))
      } else null
      val step = c.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP)?.toDouble() ?: 0.0
      val aeRange = c.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)
      val position = when (c.get(CameraCharacteristics.LENS_FACING)) {
        CameraCharacteristics.LENS_FACING_FRONT -> CameraLensPosition.FRONT
        CameraCharacteristics.LENS_FACING_BACK  -> CameraLensPosition.BACK
        else                                    -> CameraLensPosition.EXTERNAL
      }
      AndroidCameraLensCapabilities(
        equivalentFocalLength = efl,
        minZoomFactor = if (id == mainBackId) 1.0 else null,
        maxZoomFactor = c.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM)?.toDouble() ?: 1.0,
        minExposureOffset = (aeRange?.lower?.toDouble() ?: 0.0) * step,
        maxExposureOffset = (aeRange?.upper?.toDouble() ?: 0.0) * step,
        exposureOffsetStepSize = step,
        position = position,
      )
    }
  }
}
