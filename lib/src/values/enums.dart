enum CameraDetectionFaceStatus {
  undetermined,
  overOneFace,
  tooNearCamera,
  tooFarCamera,
  normal,
  notCenterCameraPreview,
}

enum CameraDetectionBrightnessStatus {
  normal,
  tooDark,
  tooBright,
}

enum CameraDetectionType {
  face,
  document,
}
