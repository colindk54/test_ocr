import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

GetIt getIt = GetIt.instance;

void dependecyInjectionSetup() {
  getIt.registerLazySingleton<TextRecognizer>(() => TextRecognizer());
}