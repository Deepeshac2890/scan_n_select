import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:scan_n_select/Components/ReusablePaddingWidget.dart';
import 'package:scan_n_select/Screens/GeneratorInfoCollector.dart';
import 'package:scan_n_select/Screens/LoginScreen.dart';

class WelcomeScreen extends StatelessWidget {
  static String id = 'Welcome_Screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.gif',
                      height: 100.0,
                      width: 150.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                TypewriterAnimatedTextKit(
                  text: ['Scan N Select'],
                  textStyle: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Hero(
              tag: 'Login',
              child: Paddy(
                      op: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                      textVal: 'Log In',
                      bColor: Colors.lightBlue)
                  .getPadding(),
            ),
            Hero(
              tag: 'Register',
              child: Paddy(
                      op: () {
                        Navigator.pushNamed(context, GeneratorInfoCollector.id);
                      },
                      textVal: 'Register',
                      bColor: Colors.blue)
                  .getPadding(),
            ),
          ],
        ),
      ),
    );
  }
}
