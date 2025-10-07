import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_ocr/ui/components/camera/camera_screen.dart';
import 'package:test_ocr/ui/components/loading/loading_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraDescription? camera;

  @override
  void initState() {
    super.initState();

    _getCamera();
  }
  
  Future<void> _getCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    cameras = cameras.where((CameraDescription camera) => camera.lensDirection == CameraLensDirection.back).toList();

    setState(() {
      camera = cameras.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(camera == null) {
      _getCamera();
    }
    return Scaffold(
      body: camera == null ? LoadingScreen(message: 'Détection de la caméra',) : CameraScreen(camera: camera!),
    );
  }
}
