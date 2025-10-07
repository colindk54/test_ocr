import 'package:flutter/material.dart';
import 'package:test_ocr/dependecy_injection.dart';
import 'package:test_ocr/ui/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  dependecyInjectionSetup();
  runApp(MaterialApp(home: const Home()));
}
