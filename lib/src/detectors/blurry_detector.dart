import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_detection/src/bindings/ffi_binding.dart';
import 'package:camera_detection/src/detectors/base_detector.dart';
import 'package:camera_detection/src/models/camera_image_buffer.dart';
import 'package:camera_detection/src/values/constants.dart';

class CameraBlurryDetector extends BaseDetector<bool> {
  /// the `threshold` value is used to check whether the camera image is blurry or not
  /// if the blurry value less than the `threshold` value, then it's blurry and otherwise
  final double threshold;

  CameraBlurryDetector({this.threshold = defaultBlurryThreshold});

  /// `detect` method used to detect whether the camera image is blurry or not
  ///
  /// `cameraImage`: image data get from the image stream of camera
  ///
  /// if method return `true` then the image is blurry, `false` then image is not blurry
  @override
  bool detect(CameraImage cameraImage) {
    double blurry = measureCameraBlurry(cameraImage);

    // if (kDebugMode) {
    //   log('camera blurry: $blurry');
    // }

    return blurry <= threshold ? true : false;
  }

  /// Calculate the blurry value of camera
  double measureCameraBlurry(CameraImage cameraImage) {
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

    final blurry = cameraBlurry(
      cameraImage.width,
      cameraImage.height,
      buffer.imageBytes,
      Platform.isAndroid,
    );

    buffer.freeMemory();
    return blurry;
  }
}
