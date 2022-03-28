import 'package:camera/camera.dart';

abstract class BaseDetector<T> {
  T detect(CameraImage cameraImage);
}
