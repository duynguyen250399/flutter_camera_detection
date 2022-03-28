import 'dart:ffi';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';

class CameraImageBuffer {
  late Pointer<Uint8> _imageBuffer;

  CameraImageBuffer.yuv({
    required CameraImage cameraImage,
  }) {
    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final ySize = yBuffer.lengthInBytes;
    final uSize = uBuffer.lengthInBytes;
    final vSize = vBuffer.lengthInBytes;
    final totalSize = ySize + uSize + vSize;

    _imageBuffer = malloc.allocate<Uint8>(totalSize);

    Uint8List bytes = _imageBuffer.asTypedList(totalSize);

    bytes.setAll(0, yBuffer);
    bytes.setAll(ySize, uBuffer);
    bytes.setAll(ySize + vSize, vBuffer);
  }

  CameraImageBuffer.rgba8888({
    required CameraImage cameraImage,
  }) {
    final buffer = cameraImage.planes[0].bytes;

    final size = buffer.lengthInBytes;

    _imageBuffer = malloc.allocate<Uint8>(size);

    Uint8List bytes = _imageBuffer.asTypedList(size);

    bytes.setAll(0, buffer);
  }

  Pointer<Uint8> get imageBytes => _imageBuffer;

  void freeMemory() {
    malloc.free(_imageBuffer);
  }
}
