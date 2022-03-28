import 'package:camera_detection/camera_detection.dart';

typedef FaceDetectionCallback = void Function(List<Face> faces);

typedef FaceAnalysisDetectionCallback = void Function(
  CameraDetectionFaceStatus status,
);

typedef BlurryDetectionCallback = void Function(bool blurry);

typedef BrightnessDetectionCallback = void Function(
    CameraDetectionBrightnessStatus brightnessStatus);
