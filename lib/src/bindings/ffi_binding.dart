import 'dart:ffi';

import 'dart:io';

import 'c_ffi_binding_type.dart';
import 'dart_ffi_binding_type.dart';

final DynamicLibrary opencv = Platform.isAndroid
    ? DynamicLibrary.open('libcamera_detection.so')
    : DynamicLibrary.process();

// Dart & C++ Function Bindings
final openCVVersion =
    opencv.lookupFunction<COpenCVVersion, DartOpenCVVersion>('version');

final cameraBrightness =
    opencv.lookupFunction<CCameraBrightness, DartCameraBrightness>(
        'cameraBrightness');

final cameraBlurry =
    opencv.lookupFunction<CCameraBlurry, DartCameraBlurry>('cameraBlurry');
