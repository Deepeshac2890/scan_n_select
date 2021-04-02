/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'package:flutter/material.dart';

class Paddy {
  Function op;
  String textVal;
  Color bColor;
  Paddy({@required this.op, @required this.textVal, @required this.bColor});
  Widget getPadding() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: bColor,
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: op,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            textVal,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
