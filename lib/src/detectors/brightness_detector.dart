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
  final int darkThreshold;

  /// the `brightThreshold` value is used to check whether the camera image is bright or dark
  /// if the brightness value less than the `brightThreshold` value, then it's too bright
  final int brightThreshold;

  CameraBrightnessDetector({
    this.darkThreshold = defaultDarkThreshold,
    this.brightThreshold = defaultBrightThreshold,
  });

  /// `detect` method used to detect whether the camera image is bright or dark
  ///
  /// `cameraImage`: image data get from the image stream of camera
  ///
  /// return the brightness status of camera: too dark, too bright or normal
  @override
  CameraDetectionBrightnessStatus detect(CameraImage cameraImage) {
    int brightness = measureCameraBrightness(cameraImage);

    // if (kDebugMode) {
    //   log('camera brightness: $brightness');
    // }

    if (brightness > darkThreshold && brightness < brightThreshold) {
      return CameraDetectionBrightnessStatus.normal;
    } else if (brightness <= darkThreshold) {
      return CameraDetectionBrightnessStatus.tooDark;
    } else {
      return CameraDetectionBrightnessStatus.tooBright;
    }
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
