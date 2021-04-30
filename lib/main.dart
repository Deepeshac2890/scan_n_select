import 'package:flutter/material.dart';
import 'package:scan_n_select/Screens/Dashboard.dart';
import 'package:scan_n_select/Screens/GeneratorInfoCollector.dart';
import 'package:scan_n_select/Screens/LoginScreen.dart';
import 'package:scan_n_select/Screens/RegistrationScreen.dart';
import 'package:scan_n_select/Screens/SuggestorInfoCollector.dart';
import 'package:scan_n_select/Screens/WelcomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        GeneratorInfoCollector.id: (context) => GeneratorInfoCollector(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        Dashboard.id: (context) => Dashboard(),
        SuggestorInfoCollector.id: (context) => SuggestorInfoCollector(),
      },
      initialRoute: WelcomeScreen.id,
    );
  }
}
