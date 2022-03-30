import 'dart:io';

import 'package:camera_detection/camera_detection.dart';
import 'package:camera_detection/src/values/typedefs.dart';
import 'package:flutter/material.dart';

enum CameraDetectionBoxStatus {
  idle,
  success,
  error,
}

class CameraDetectionBox extends StatefulWidget {
  const CameraDetectionBox({
    Key? key,
    this.detectionType = CameraDetectionType.face,
    this.status = CameraDetectionBoxStatus.idle,
    this.message,
    this.effectDetectionOptions = const CameraEffectDetectionOptions(),
    this.faceDetectionOptions = const CameraFaceDetectionOptions(),
    this.blurryDetectionOptions = const CameraBlurryOptions(),
    this.brightnessDetectionOptions = const CameraBrightnessOptions(),
    this.cameraResolution = ResolutionPreset.medium,
    this.cameraLensDirection = CameraLensDirection.back,
    this.enableAudio = false,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.errorBorder,
    this.successBorder,
    this.outerBorderGap = 14,
    this.errorTextStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: Color(0xffEB5757),
    ),
    this.successTextStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: Color(0xff38CB89),
    ),
    this.enableDetection = false,
    this.onInitializeDone,
  }) : super(key: key);

  final CameraDetectionType detectionType;
  final CameraDetectionBoxStatus status;
  final String? message;
  final CameraEffectDetectionOptions effectDetectionOptions;
  final CameraFaceDetectionOptions faceDetectionOptions;
  final CameraBlurryOptions blurryDetectionOptions;
  final CameraBrightnessOptions brightnessDetectionOptions;
  final ResolutionPreset cameraResolution;
  final CameraLensDirection cameraLensDirection;
  final bool enableAudio;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxBorder? errorBorder;
  final BoxBorder? successBorder;
  final BoxBorder? border;
  final TextStyle errorTextStyle;
  final TextStyle successTextStyle;
  final double outerBorderGap;
  final bool enableDetection;
  final CameraDetectionBoxInitializationDone? onInitializeDone;

  @override
  State<CameraDetectionBox> createState() => _CameraDetectionBoxState();
}

class _CameraDetectionBoxState extends State<CameraDetectionBox>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _faceDetecting = false;
  final ValueNotifier<String?> _detectError = ValueNotifier<String?>(null);

  CameraDetectionFaceStatus? _prevFaceStatus;

  Future<void>? _initialization;

  CameraFaceDetector? _faceDetector;
  CameraBlurryDetector? _blurryDetector;
  CameraBrightnessDetector? _brightnessDetector;

  void _initDetectors() {
    if (widget.enableDetection) {
      if (widget.detectionType == CameraDetectionType.face) {
        _faceDetector = CameraFaceDetector(
          options: widget.faceDetectionOptions.detectorOptions,
          farThreshold: widget.faceDetectionOptions.farThreshold,
          nearThreshold: widget.faceDetectionOptions.nearThreshold,
        );
      }

      final _effectDetectionOptions = widget.effectDetectionOptions;

      if (_effectDetectionOptions.allowDetectBlurry) {
        _blurryDetector = CameraBlurryDetector(
          threshold: widget.blurryDetectionOptions.blurryThreshold,
        );
      }

      if (_effectDetectionOptions.allowDetectBrightness) {
        _brightnessDetector = CameraBrightnessDetector(
          darkThreshold: widget.brightnessDetectionOptions.darkThreshold,
          brightThreshold: widget.brightnessDetectionOptions.brightThreshold,
        );
      }
    }
  }

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
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController?.initialize();

      final initializeDone = widget.onInitializeDone;
      if (initializeDone != null) {
        initializeDone(_cameraController);
      }

      if (widget.enableDetection) {
        _cameraController?.startImageStream(_processCameraImage);
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    if (!mounted || !widget.enableDetection) return;

    if (_brightnessDetector != null) {
      final brightnessStatus = _brightnessDetector?.detect(image) ??
          CameraDetectionBrightnessStatus.normal;

      if (brightnessStatus == CameraDetectionBrightnessStatus.tooBright) {
        _detectError.value = 'Hình ảnh quá sáng';
        return;
      }

      if (brightnessStatus == CameraDetectionBrightnessStatus.tooDark) {
        _detectError.value = 'Hình ảnh quá tối';
        return;
      }
    }

    if (_blurryDetector != null) {
      final blurry = _blurryDetector?.detect(image) ?? false;
      if (blurry) {
        _detectError.value = 'Giữ điện thoại không bị rung';
        return;
      }
    }

    if (_faceDetector != null) {
      if (!_faceDetecting) {
        _faceDetecting = true;

        CameraDetectionFaceStatus? faceStatus;

        final cameraRotation = _cameraController!.description.sensorOrientation;

        _faceDetector?.detect(image, rotation: cameraRotation).then((faces) {
          final previewSize = Size(
            widget.width,
            widget.height,
          );

          faceStatus = _faceDetector?.analyzeFaces(
            faces,
            previewSize: previewSize,
            image: image,
            cameraLensDirection: _cameraController!.description.lensDirection,
          );
        }).whenComplete(
          () {
            debugPrint(faceStatus.toString());
            var _tmpFaceStatus = faceStatus;
            if (_prevFaceStatus == CameraDetectionFaceStatus.tooNearCamera &&
                _tmpFaceStatus == CameraDetectionFaceStatus.undetermined) {
              _tmpFaceStatus = CameraDetectionFaceStatus.tooNearCamera;
            }

            if (_prevFaceStatus == CameraDetectionFaceStatus.tooFarCamera &&
                _tmpFaceStatus ==
                    CameraDetectionFaceStatus.notCenterCameraPreview) {
              _tmpFaceStatus = CameraDetectionFaceStatus.tooFarCamera;
            }

            final error = _getFaceStatusErrorMessage(_tmpFaceStatus);
            if (_detectError.value != error) {
              _detectError.value = error;
            }

            _prevFaceStatus = _tmpFaceStatus;

            _faceDetecting = false;
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initDetectors();
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
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: widget.width + widget.outerBorderGap,
          height: widget.height + widget.outerBorderGap,
          decoration: BoxDecoration(
            border: widget.status == CameraDetectionBoxStatus.idle
                ? widget.border
                : widget.status == CameraDetectionBoxStatus.error
                    ? widget.errorBorder
                    : widget.successBorder,
            borderRadius: widget.borderRadius,
          ),
          child: Center(
            child: SizedBox(
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
                              final done = snapshot.connectionState ==
                                      ConnectionState.done &&
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
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        if (widget.status == CameraDetectionBoxStatus.idle)
          ValueListenableBuilder<String?>(
            valueListenable: _detectError,
            builder: (context, error, child) {
              return Text(
                error ?? '',
                style: widget.errorTextStyle,
              );
            },
          )
        else
          Text(
            widget.message ?? '',
            style: widget.status == CameraDetectionBoxStatus.error
                ? widget.errorTextStyle
                : widget.successTextStyle,
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container();
  }

  Widget _buildResult() {
    return CameraPreview(_cameraController!);
  }

  String? _getFaceStatusErrorMessage(CameraDetectionFaceStatus? faceStatus) {
    switch (faceStatus) {
      case CameraDetectionFaceStatus.normal:
        return null;
      case CameraDetectionFaceStatus.overOneFace:
        return 'Chỉ đặt một khuôn mặt trong khung hình';
      case CameraDetectionFaceStatus.tooFarCamera:
        return 'Di chuyển điện thoại lại gần hơn';
      case CameraDetectionFaceStatus.tooNearCamera:
        return 'Di chuyển điện thoại ra xa hơn';
      case CameraDetectionFaceStatus.undetermined:
      case CameraDetectionFaceStatus.notCenterCameraPreview:
        return 'Đặt khuôn mặt trong khung hình';
      default:
        return null;
    }
  }
}
