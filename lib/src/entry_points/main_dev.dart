import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options_dev.dart';
import '../app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("--- FIREBASE USPJEŠNO UPALJEN ---");
  } catch (e) {
    print("--- GREŠKA: $e ---");
  }

  runApp(const App(flavor: 'dev'));
}