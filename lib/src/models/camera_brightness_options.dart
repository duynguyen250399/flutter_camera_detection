import 'package:camera_detection/src/values/constants.dart';

class CameraBrightnessOptions {
  final int darkThreshold;
  final int brightThreshold;

  const CameraBrightnessOptions({
    this.darkThreshold = defaultDarkThreshold,
    this.brightThreshold = defaultBrightThreshold,
  });
}
