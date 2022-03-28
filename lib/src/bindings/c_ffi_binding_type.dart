// C++ Function Types
import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef COpenCVVersion = Pointer<Utf8> Function();
typedef CCameraBrightness = Int32 Function(
  Int32 width,
  Int32 height,
  Pointer<Uint8> bytes,
  Bool isYUV,
);
typedef CCameraBlurry = Double Function(
  Int32 width,
  Int32 height,
  Pointer<Uint8> bytes,
  Bool isYUV,
);
