import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerPainter extends CustomPainter {
  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final RenderBox renderBox;
  final Paint? paintboxCustom;

  String scannedText = '';

  TextRecognizerPainter(
    this.recognizedText,
    this.absoluteImageSize,
    this.rotation,
    this.renderBox,
    this.paintboxCustom,
  );

  @override
  void paint(Canvas canvas, Size size) {
    scannedText = '';

  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}
