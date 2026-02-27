import 'package:flutter/material.dart';
import 'src/app.dart';

void runFlavoredApp(String flavor) {
  // Ovdje sada proslijeđujemo 'flavor' našoj aplikaciji!
  runApp(App(flavor: flavor)); 
}