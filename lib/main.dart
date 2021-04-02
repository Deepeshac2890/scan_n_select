import 'package:flutter/material.dart';
import 'package:scan_n_select/Screens/GeneratorInfoCollector.dart';
import 'package:scan_n_select/Screens/LoginScreen.dart';
import 'package:scan_n_select/Screens/RegistrationScreen.dart';
import 'package:scan_n_select/Screens/Scanner.dart';
import 'package:scan_n_select/Screens/WelcomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        Scanner.id: (context) => Scanner(),
        GeneratorInfoCollector.id: (context) => GeneratorInfoCollector(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        Scanner.id: (context) => Scanner(),
      },
      initialRoute: WelcomeScreen.id,
    );
  }
}
