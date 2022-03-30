import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:camera_detection/src/detectors/base_detector.dart';
import 'package:camera_detection/src/values/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

class CameraFaceDetector extends BaseDetector<Future<List<Face>>> {
  /// Face detector otions from package `google_ml_kit`
  final FaceDetectorOptions? options;

  /// The value should be from 0.1 to 1.0
  final double farThreshold;

  /// The value should be from 0.1 to 1.0
  final double nearThreshold;

  late final FaceDetector _faceDetector;

  CameraFaceDetector({
    this.options,
    this.farThreshold = 0.3,
    this.nearThreshold = 0.5,
  }) {
    assert(farThreshold > 0 && farThreshold <= 1);
    assert(nearThreshold > 0 && nearThreshold <= 1);

    _faceDetector = GoogleVision.instance.faceDetector(options);
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

    final ImageRotation imageRotation = _intToImageRotation(rotation ?? 0);

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return GoogleVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = GoogleVisionImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      rawFormat: cameraImage.format.raw,
      planeData: planeData,
    );

    final GoogleVisionImage imageToDetect = GoogleVisionImage.fromBytes(
      imageBytes,
      inputImageData,
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
    Offset? faceCenterOffset,
  }) {
    if (faces.isEmpty) {
      return CameraDetectionFaceStatus.undetermined;
    }

    if (faces.length > 1) {
      return CameraDetectionFaceStatus.overOneFace;
    }

    // Calculate the scale ratio between the original camera image size
    // with actual camera preview size
    final scaleX = previewSize.width / image.width.toDouble();
    final scaleY = previewSize.height / image.height.toDouble();

    final face = faces.first;

    final box = face.boundingBox;

    final top = box.top * scaleY;

    final bottom = box.bottom * scaleY;

    final left = (cameraLensDirection == CameraLensDirection.front)
        ? previewSize.width - box.right * scaleX
        : box.left * scaleX;

    final right = (cameraLensDirection == CameraLensDirection.front)
        ? previewSize.width - box.left * scaleX
        : box.right * scaleX;

    final rect = Rect.fromLTRB(left, top, right, bottom);

    if (rect.width >= previewSize.width * nearThreshold) {
      return CameraDetectionFaceStatus.tooNearCamera;
    } else if (rect.width < previewSize.width * farThreshold) {
      return CameraDetectionFaceStatus.tooFarCamera;
    }

    // Detect whenever the user's face is inside the camera preview or not
    final insideCameraPreviewBox = left > 0 &&
        right < previewSize.width &&
        top > 0 &&
        top < previewSize.height;

    if (!insideCameraPreviewBox) {
      return CameraDetectionFaceStatus.outsideBox;
    }

    // Calculate the offset which will be subtract when detect the user's face is center or not center
    // within camera preview
    final xCenterOffset = faceCenterOffset?.dx ?? previewSize.width / 6.0;
    final yCenterOffset = faceCenterOffset?.dy ?? previewSize.height / 6.0;

    final centerCameraPreviewBox = left > xCenterOffset &&
        right < previewSize.width - xCenterOffset &&
        top > yCenterOffset &&
        top < previewSize.height - yCenterOffset;

    if (!centerCameraPreviewBox) {
      return CameraDetectionFaceStatus.notCenterCameraPreview;
    }

    // If all conditions above passed, the face is perfectly normal
    // So we can capture it!
    return CameraDetectionFaceStatus.normal;
  }

  Uint8List _getBytesFromImagePlanes(List<Plane> planes) {
    final WriteBuffer bytes = WriteBuffer();

    for (final plane in planes) {
      bytes.putUint8List(plane.bytes);
    }

    return bytes.done().buffer.asUint8List();
  }

  ImageRotation _intToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      case 270:
        return ImageRotation.rotation270;
      default:
        return ImageRotation.rotation0;
    }
  }

  void close() {
    _faceDetector.close();
  }
}
