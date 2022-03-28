import 'dart:developer';

import 'package:camera_detection/camera_detection.dart';
import 'package:camera_detection/src/values/typedefs.dart';
import 'package:flutter/material.dart';

class CameraDetectionBox extends StatefulWidget {
  const CameraDetectionBox({
    Key? key,
    this.cameraResolution = ResolutionPreset.medium,
    this.cameraLensDirection = CameraLensDirection.back,
    this.enableAudio = false,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = BorderRadius.zero,
    this.enableDetection = false,
    this.faceDetector,
    this.blurryDetector,
    this.brightnessDetector,
    this.onFaceDetection,
    this.onFaceAnalysisDetection,
    this.onBlurryDetection,
    this.onBrightnessDetection,
    this.faceDistanceDetectVariantOffset = const Offset(0.5, 0.3),
  }) : super(key: key);

  final ResolutionPreset cameraResolution;
  final CameraLensDirection cameraLensDirection;
  final bool enableAudio;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final bool enableDetection;
  final CameraFaceDetector? faceDetector;
  final CameraBrightnessDetector? brightnessDetector;
  final CameraBlurryDetector? blurryDetector;
  final FaceDetectionCallback? onFaceDetection;
  final FaceAnalysisDetectionCallback? onFaceAnalysisDetection;
  final BlurryDetectionCallback? onBlurryDetection;
  final BrightnessDetectionCallback? onBrightnessDetection;

  /// The variance offset to estimate the distance of face which is near or far
  /// from camera
  final Offset faceDistanceDetectVariantOffset;

  @override
  State<CameraDetectionBox> createState() => _CameraDetectionBoxState();
}

class _CameraDetectionBoxState extends State<CameraDetectionBox>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _effectDetecting = false;
  bool _faceDetecting = false;

  Future<void>? _initialization;

  Future<void> _initCamera() async {
    final _cameras = await availableCameras();

    if (_cameras.isNotEmpty) {
      final camera = _cameras.firstWhere(
        (cam) => cam.lensDirection == widget.cameraLensDirection,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        widget.cameraResolution,
        enableAudio: widget.enableAudio,
      );

      await _cameraController?.initialize();
      if (widget.enableDetection) {
        _cameraController?.startImageStream(_processCameraImage);
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    if (!mounted) return;

    if (!_effectDetecting) {
      _effectDetecting = true;

      if (widget.brightnessDetector != null) {
        final sw = Stopwatch()..start();
        final brightnessStatus = widget.brightnessDetector?.detect(image) ??
            CameraDetectionBrightnessStatus.normal;
        log('Detect brightness execution time: ${sw.elapsedMilliseconds} ms');

        final _brightnessDetection = widget.onBrightnessDetection;

        if (_brightnessDetection != null) {
          _brightnessDetection(brightnessStatus);
        }
      }

      if (widget.blurryDetector != null) {
        final sw = Stopwatch()..start();
        final blurry = widget.blurryDetector?.detect(image) ?? false;
        log('Detect blurry execution time: ${sw.elapsedMilliseconds} ms');
        final _blurryDetection = widget.onBlurryDetection;
        if (_blurryDetection != null) {
          _blurryDetection(blurry);
        }
      }

      _effectDetecting = false;
    }

    if (widget.faceDetector != null) {
      if (!_faceDetecting) {
        _faceDetecting = true;
        final sw = Stopwatch()..start();
        widget.faceDetector?.detect(image).then((faces) {
          final _faceDetection = widget.onFaceDetection;
          final _faceAnalysisDetection = widget.onFaceAnalysisDetection;

          if (_faceDetection != null) {
            _faceDetection(faces);
          }

          if (_faceAnalysisDetection != null) {
            final previewSize = Size(
              widget.width,
              widget.height,
            );

            final faceStatus = widget.faceDetector?.analyzeFaces(
              faces,
              previewSize: previewSize,
              image: image,
              cameraLensDirection: _cameraController!.description.lensDirection,
            );

            if (faceStatus != null) {
              _faceAnalysisDetection(faceStatus);
            }
          }
        }).whenComplete(
          () {
            _faceDetecting = false;
            log('Detect face execution time: ${sw.elapsedMilliseconds} ms');
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initialization = _initCamera();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        _initialization = _initCamera();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final width = constraints.maxWidth;

          return ClipRRect(
            borderRadius: widget.borderRadius,
            child: OverflowBox(
              maxHeight: double.infinity,
              maxWidth: double.infinity,
              child: SizedBox(
                width: width,
                child: FutureBuilder<void>(
                    future: _initialization,
                    builder: (context, snapshot) {
                      final done =
                          snapshot.connectionState == ConnectionState.done &&
                              _cameraController != null &&
                              _cameraController!.value.isInitialized;

                      if (!done) {
                        return _buildLoading();
                      }

                      return _buildResult();
                    }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Container();
  }

  Widget _buildResult() {
    return CameraPreview(_cameraController!);
  }
}
