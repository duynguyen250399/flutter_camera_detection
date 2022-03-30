import 'package:camera_detection/camera_detection.dart';

class CameraFaceDetectionOptions {
  final FaceDetectorOptions? detectorOptions;
  final double farThreshold;
  final double nearThreshold;

  const CameraFaceDetectionOptions({
    this.detectorOptions,
    this.farThreshold = 0.3,
    this.nearThreshold = 0.5,
  });
}
