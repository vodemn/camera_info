package com.vodemn.camera_info

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.util.Log
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

  override fun getCameraInfo(): List<AndroidCameraLensInfo> {
    val ids = cameraManager.cameraIdList
    Log.d(TAG, "cameraIdList: ${ids.toList()}")

    val mainBackId = ids.firstOrNull { id ->
      cameraManager.getCameraCharacteristics(id)
        .get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_BACK
    }
    Log.d(TAG, "mainBackId: $mainBackId")

    return ids.map { id ->
      val c = cameraManager.getCameraCharacteristics(id)

      val facingRaw = c.get(CameraCharacteristics.LENS_FACING)
      val facingLabel = when (facingRaw) {
        CameraCharacteristics.LENS_FACING_FRONT    -> "FRONT"
        CameraCharacteristics.LENS_FACING_BACK     -> "BACK"
        CameraCharacteristics.LENS_FACING_EXTERNAL -> "EXTERNAL"
        else                                       -> "UNKNOWN($facingRaw)"
      }

      val focalLengths = c.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
      val sensorSize    = c.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)
      val maxZoom       = c.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM)
      val focalLength   = focalLengths?.firstOrNull()
      val efl = if (focalLength != null && sensorSize != null) {
        43.27 * focalLength / sqrt(sensorSize.height.pow(2) + sensorSize.width.pow(2))
      } else null

      val cameraFeatures = c.get(CameraCharacteristics.REQUEST_AVAILABLE_CAPABILITIES)
      val isDepth = cameraFeatures?.contains(
        CameraCharacteristics.REQUEST_AVAILABLE_CAPABILITIES_DEPTH_OUTPUT
      ) == true
      val minFocusDist = c.get(CameraCharacteristics.LENS_INFO_MINIMUM_FOCUS_DISTANCE)
      val hwLevel = when (c.get(CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL)) {
        CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY   -> "LEGACY"
        CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED  -> "LIMITED"
        CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_FULL     -> "FULL"
        CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_3        -> "LEVEL_3"
        CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL -> "EXTERNAL"
        else -> "UNKNOWN"
      }

      Log.d(TAG, buildString {
        appendLine("--- Camera id=$id ---")
        appendLine("  facing              : $facingLabel")
        appendLine("  isMain              : ${id == mainBackId}")
        appendLine("  hwLevel             : $hwLevel")
        appendLine("  isDepthSensor       : $isDepth")
        appendLine("  minFocusDist        : $minFocusDist")
        appendLine("  focalLengths (mm)   : ${focalLengths?.toList()}")
        appendLine("  sensorSize          : $sensorSize")
        appendLine("  efl (35mm equiv mm) : $efl")
        appendLine("  maxDigitalZoom      : $maxZoom")
        val aeStep  = c.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP)
        val aeRange = c.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)
        appendLine("  aeRange             : $aeRange")
        appendLine("  aeStep              : $aeStep")
        append("  features            : ${cameraFeatures?.toList()}")
      })

      val step    = c.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP)?.toDouble() ?: 0.0
      val aeRange = c.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)
      val position = when (facingRaw) {
        CameraCharacteristics.LENS_FACING_FRONT -> CameraLensPosition.FRONT
        CameraCharacteristics.LENS_FACING_BACK  -> CameraLensPosition.BACK
        else                                    -> CameraLensPosition.EXTERNAL
      }
      AndroidCameraLensInfo(
        equivalentFocalLength = efl,
        minZoomFactor = if (id == mainBackId) 1.0 else null,
        maxZoomFactor = maxZoom?.toDouble() ?: 1.0,
        minExposureOffset = (aeRange?.lower?.toDouble() ?: 0.0) * step,
        maxExposureOffset = (aeRange?.upper?.toDouble() ?: 0.0) * step,
        exposureOffsetStepSize = step,
        position = position,
        isMain = id == mainBackId,
      )
    }
  }

  companion object {
    private const val TAG = "CameraInfo"
  }
}
