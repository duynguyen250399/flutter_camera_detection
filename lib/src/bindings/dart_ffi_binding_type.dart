// Dart Function Types
import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef DartOpenCVVersion = Pointer<Utf8> Function();
typedef DartCameraBrightness = int Function(
  int width,
  int height,
  Pointer<Uint8> bytes,
  bool isYUV,
);
typedef DartCameraBlurry = double Function(
  int width,
  int height,
  Pointer<Uint8> bytes,
  bool isYUV,
);
