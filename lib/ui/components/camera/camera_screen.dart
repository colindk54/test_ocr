import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:test_ocr/dependecy_injection.dart';
import 'package:test_ocr/ui/components/orientation/device_orientation_manager.dart';
import 'package:test_ocr/ui/components/painter/text_recognizer_painter.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _busy = false;
  bool _converting = false;
  CustomPaint? customPaint;
  final GlobalKey cameraPrev = GlobalKey();

  final StreamController<String> streamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
                .nv21 // for Android
          : ImageFormatGroup.bgra8888,
    );
    _controller
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          startLiveStream();
          setState(() {});
        })
        .catchError((Object e) {
          debugPrint(e.toString());
        });
  }

  Future<void> stopLiveStream() async {
    await _controller.stopImageStream();
  }

  Future<void> startLiveStream() async {
    _controller.startImageStream(_processCameraImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future<void> _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final camera = _controller.description;

    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? imageRotation;
    if (Platform.isIOS) {
      imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller.value.deviceOrientation];
      if (rotationCompensation == null) return;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      imageRotation = InputImageRotationValue.fromRawValue(
        rotationCompensation,
      );
    }
    if (imageRotation == null) return;

    final imageFormat = InputImageFormatValue.fromRawValue(image.format.raw);

    if (imageFormat == null ||
        (Platform.isAndroid && imageFormat != InputImageFormat.nv21) ||
        (Platform.isIOS && imageFormat != InputImageFormat.bgra8888))
      return;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return;

    final planeData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: imageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: planeData);

    _processImage(inputImage);
  }

  @override
  void dispose() {
    stopLiveStream();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamController.stream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return DeviceOrientationManager(
          spacing: 5,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Center(
                  child: SizedBox(
                    key: cameraPrev,
                    child: CameraPreview(
                      _controller,
                      child: Stack(
                        children: [
                          Align(
                            alignment: AlignmentGeometry.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                  color: Colors.white.withAlpha(200),
                                ),
                                child: Icon(Icons.camera, size: 80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (customPaint != null)
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          return customPaint!;
                        },
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(child: Text(snapshot.data ?? '')),
            ),
          ],
        );
      },
    );
  }

  final RegExp vinRegExp = RegExp('r^[0-9a-zA-Z]{17}\$');

  Future<void> _processImage(InputImage inputImage) async {
    if (_busy) return;
    _busy = true;
    final TextRecognizer textRecognizer = getIt.get<TextRecognizer>();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        recognizedText.blocks.isNotEmpty &&
        cameraPrev.currentContext != null) {
      _setText(recognizedText.toJson());
      final RenderBox renderBox =
          cameraPrev.currentContext?.findRenderObject() as RenderBox;

      TextRecognizerPainter painter = TextRecognizerPainter(
        recognizedText,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        renderBox,
        null,
      );
      customPaint = CustomPaint(painter: painter);
      /*
      var painter = TextRecognizerPainter(
          recognizedText,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          renderBox, (value) {
        widget.getScannedText(value);
      }, getRawData: (value) {
        if (widget.getRawData != null) {
          widget.getRawData!(value);
        }
      },
          boxBottomOff: widget.boxBottomOff,
          boxTopOff: widget.boxTopOff,
          boxRightOff: widget.boxRightOff,
          boxLeftOff: widget.boxRightOff,
          paintboxCustom: widget.paintboxCustom);

      customPaint = CustomPaint(painter: painter);*/
    } else {
      customPaint = null;
    }
    _busy = false;
    setState(() {});
  }

  void _setText(String json) {
    streamController.add(json);
  }
}

extension on RecognizedText {
  String toJson() {
    return 'RecognizedText : $text';
  }
}
