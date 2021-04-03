/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scan_n_select/Components/ReusablePaddingWidget.dart';
import 'package:scan_n_select/Screens/SuggestorInfoCollector.dart';

import '../Constants.dart';

/*
For Personal Reference
* Elements Used here :
* Alert
* builder for Scaffold
* ModalProgressHud
* Hero to add the smooth transition animation for images between 2 screens
* Flexible Widget
* SnackBar
* GestureDetector
*/

class LoginScreen extends StatefulWidget {
  static String id = 'Login_Screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

final FirebaseAuth fa = FirebaseAuth.instance;

class _LoginScreenState extends State<LoginScreen> {
  bool isSpinning = false;
  String emailId;
  String passwd;

  void login() async {
    setState(() {
      isSpinning = true;
    });
    try {
      final user =
          await fa.signInWithEmailAndPassword(email: emailId, password: passwd);
      if (user != null) {
        setState(() {
          isSpinning = false;
        });
        Navigator.pushNamed(context, SuggestorInfoCollector.id);
      }
    } catch (e) {
      print(e);
      setState(() {
        isSpinning = false;
        Alert(
                context: context,
                title: "Please Try Again",
                desc: "Invalid Credentials")
            .show();
      });
    }
  }

  var forgotEmailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (BuildContext innerContext) {
            return ModalProgressHUD(
              inAsyncCall: isSpinning,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          child: Image.asset(
                            'assets/logo.gif',
                            height: 200.0,
                            width: 200.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48.0,
                    ),
                    GestureDetector(
                      onHorizontalDragDown: (DragDownDetails) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      },
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          emailId = value;
                        },
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Email',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    GestureDetector(
                      onHorizontalDragDown: (DragDownDetails) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      },
                      child: TextField(
                        textAlign: TextAlign.center,
                        obscureText: true,
                        onChanged: (value) {
                          passwd = value;
                        },
                        decoration: kTextFieldDecoration,
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Hero(
                      tag: 'Login',
                      child: Paddy(
                              op: () {
                                login();
                              },
                              textVal: 'Login',
                              bColor: Colors.blue)
                          .getPadding(),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        child: Text('Forgot Password ?'),
                        onPressed: () {
                          // Implement Forgot Password Page
                          Alert(
                            context: context,
                            title: 'Forgot Password',
                            content: Column(
                              children: [
                                GestureDetector(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.account_circle),
                                      labelText: 'Username',
                                    ),
                                    onChanged: (value) {
                                      // Do something
                                    },
                                    controller: forgotEmailController,
                                  ),
                                  onHorizontalDragDown: (dragDownDetails) {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                  },
                                ),
                              ],
                            ),
                            buttons: [
                              DialogButton(
                                onPressed: () async {
                                  var email = forgotEmailController.text;
                                  try {
                                    await fa.sendPasswordResetEmail(
                                        email: email);
                                    Scaffold.of(innerContext).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Link has been sent to Registered Email-Id',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    Scaffold.of(innerContext).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Invalid Email Id. Try Again !',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                  forgotEmailController.clear();
                                },
                                child: Text(
                                  "Request",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ],
                          ).show();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
