import 'dart:io';

import 'package:camera_detection/camera_detection.dart';
import 'package:camera_detection/src/bindings/ffi_binding.dart';
import 'package:camera_detection/src/detectors/base_detector.dart';
import 'package:camera_detection/src/models/camera_image_buffer.dart';
import 'package:camera_detection/src/values/constants.dart';

class CameraBrightnessDetector
    extends BaseDetector<CameraDetectionBrightnessStatus> {
  /// the `darkThreshold` value is used to check whether the camera image is bright or dark
  /// if the brightness value less than the `darkThreshold` value, then it's too dark
  /// the value must be between 0 - 255
  final int darkThreshold;

  /// the `brightThreshold` value is used to check whether the camera image is bright or dark
  /// if the brightness value less than the `brightThreshold` value, then it's too bright
  /// the value must be between 0 - 255
  final int brightThreshold;

  CameraBrightnessDetector({
    this.darkThreshold = defaultDarkThreshold,
    this.brightThreshold = defaultBrightThreshold,
  })  : assert(darkThreshold >= 0 && darkThreshold <= 255),
        assert(brightThreshold >= 0 && brightThreshold <= 255);

  /// `detect` method used to detect whether the camera image is bright or dark
  ///
  /// `cameraImage`: image data get from the image stream of camera
  ///
  /// return the brightness status of camera: too dark, too bright or normal
  @override
  CameraDetectionBrightnessStatus detect(CameraImage cameraImage) {
    int brightness = measureCameraBrightness(cameraImage);

    if (brightness <= darkThreshold) {
      return CameraDetectionBrightnessStatus.tooDark;
    }

    if (brightness >= brightThreshold) {
      return CameraDetectionBrightnessStatus.tooBright;
    }

    return CameraDetectionBrightnessStatus.normal;
  }

  /// Calculate the brightness of camera
  int measureCameraBrightness(CameraImage cameraImage) {
    CameraImageBuffer buffer;

    if (Platform.isAndroid) {
      buffer = CameraImageBuffer.yuv(
        cameraImage: cameraImage,
      );
    } else {
      buffer = CameraImageBuffer.rgba8888(
        cameraImage: cameraImage,
      );
    }

    int brightness = cameraBrightness(
      cameraImage.width,
      cameraImage.height,
      buffer.imageBytes,
      Platform.isAndroid,
    );

    buffer.freeMemory();
    return brightness;
  }
}
