import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:camera_detection/src/detectors/base_detector.dart';
import 'package:camera_detection/src/values/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraFaceDetector extends BaseDetector<Future<List<Face>>> {
  /// Face detector otions from package `google_ml_kit`
  final FaceDetectorOptions? options;
  final double farThreshold;
  final double nearThreshold;

  late final FaceDetector _faceDetector;

  CameraFaceDetector({
    this.options,
    this.farThreshold = 0.3,
    this.nearThreshold = 0.5,
  }) {
    assert(farThreshold > 0 && farThreshold <= 1);
    assert(nearThreshold > 0 && nearThreshold <= 1);

    _faceDetector = GoogleMlKit.vision.faceDetector(options);
  }

  /// `detect` method used to detect human faces in camera
  ///
  /// `cameraImage`: image data get from the image stream of camera
  ///
  /// `rotation`: rotation get from orientation sensor of device
  ///
  /// return the list of detected faces
  @override
  Future<List<Face>> detect(
    CameraImage cameraImage, {
    int? rotation,
  }) async {
    final imageBytes = _getBytesFromImagePlanes(cameraImage.planes);

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
              rotation ?? 0,
            ) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.NV21;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final InputImage imageToDetect = InputImage.fromBytes(
      bytes: imageBytes,
      inputImageData: inputImageData,
    );

    final result = await _faceDetector.processImage(imageToDetect);

    return result;
  }

  /// `detectCameraFaceStatus` method used to detect human faces and analysis them in camera
  ///
  /// `cameraImage`: image data get from the image stream of camera
  ///
  /// `rotation`: rotation get from orientation sensor of device
  ///
  /// `previewSize`: the size of camera preview
  ///
  /// `cameraLensDirection`: the lens direction of camera, it could be front or rear
  ///
  /// return `CameraDetectionFaceStatus` indicate for face status
  Future<CameraDetectionFaceStatus> detectCameraFaceStatus(
    CameraImage image, {
    int? rotation,
    required Size previewSize,
    required CameraLensDirection cameraLensDirection,
  }) async {
    final faces = await detect(image, rotation: rotation);

    return analyzeFaces(
      faces,
      previewSize: previewSize,
      image: image,
      cameraLensDirection: cameraLensDirection,
    );
  }

  /// `analyzeFaces` method used to detect human faces and analysis them in camera
  ///
  /// `faces`: List of detected faces
  ///
  /// `image`: image data get from the image stream of camera
  ///
  /// `previewSize`: the size of camera preview
  ///
  /// `cameraLensDirection`: the lens direction of camera, it could be front or rear
  ///
  /// return `CameraDetectionFaceStatus` indicate for face status
  CameraDetectionFaceStatus analyzeFaces(
    List<Face> faces, {
    required Size previewSize,
    required CameraImage image,
    required CameraLensDirection cameraLensDirection,
  }) {
    if (faces.isEmpty) {
      return CameraDetectionFaceStatus.undetermined;
    }

    if (faces.length > 1) {
      return CameraDetectionFaceStatus.overOneFace;
    }

    final scaleX = previewSize.width / image.width.toDouble();
    final scaleY = previewSize.height / image.height.toDouble();

    final face = faces.first;

    final box = face.boundingBox;

    final top = box.top * scaleY;

    final bottom = box.bottom * scaleY;

    final left = (cameraLensDirection == CameraLensDirection.front)
        ? (previewSize.width - box.right) * scaleX
        : box.left * scaleX;

    final right = (cameraLensDirection == CameraLensDirection.front)
        ? (previewSize.width - box.left) * scaleX
        : box.right * scaleX;

    final rect = Rect.fromLTRB(left, top, right, bottom);

    if (rect.width >= previewSize.width * nearThreshold) {
      return CameraDetectionFaceStatus.tooNearCamera;
    } else if (rect.width < previewSize.width * farThreshold) {
      return CameraDetectionFaceStatus.tooFarCamera;
    } else {
      return CameraDetectionFaceStatus.normal;
    }
  }

  Uint8List _getBytesFromImagePlanes(List<Plane> planes) {
    final WriteBuffer bytes = WriteBuffer();

    for (final plane in planes) {
      bytes.putUint8List(plane.bytes);
    }

    return bytes.done().buffer.asUint8List();
  }
}
