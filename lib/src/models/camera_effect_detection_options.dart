class CameraEffectDetectionOptions {
  final bool allowDetectBrightness;
  final bool allowDetectBlurry;

  const CameraEffectDetectionOptions({
    this.allowDetectBlurry = false,
    this.allowDetectBrightness = false,
  });
}
