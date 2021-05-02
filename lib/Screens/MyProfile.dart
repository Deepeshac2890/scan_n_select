/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

/*
For Personal Reference
* Elements Used here :
* Compress File
* ModalProgressHUD
*/

// TODO: Add more information in this portion
// TODO: Add edit option for certain details

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  FirebaseAuth fa = FirebaseAuth.instance;
  Firestore fs = Firestore.instance;
  FirebaseStorage fbs = FirebaseStorage.instance;
  String imgUrl;
  String name = '';
  String email = '';
  AnimationController _resizableController;
  var loggedUser;
  File imageClicked;
  File imgFile;
  bool isSpinning = false;
  bool showUpload = false;
  Image img = Image.asset('assets/profile.png');
  final picker = ImagePicker();
  Image oldPic = Image.asset('assets/profile.png');

  AnimatedBuilder getContainer() {
    return new AnimatedBuilder(
        animation: _resizableController,
        builder: (context, child) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              child: CircleAvatar(
                radius: 100,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                    color: Colors.blue,
                    width: _resizableController.value * 10 + 1),
              ),
            ),
          );
        });
  }

  void currentUser() async {
    loggedUser = await fa.currentUser();
    getData();
  }

  void getData() async {
    var data = await fs
        .collection('Users')
        .document(loggedUser.uid)
        .collection('Details')
        .document('Details')
        .get();
    String namea = await data.data['Name'];
    String emaila = await data.data['Email'];
    String imgUrla = await data.data['Profile Image'];

    setState(() {
      name = namea;
      email = emaila;
      imgUrl = imgUrla;
      if (imgUrl.isNotEmpty) {
        try {
          img = Image.network(imgUrl);
        } catch (e) {
          img = Image.asset('assets/profile.png');
        }
      }
    });
  }

  @override
  void initState() {
    currentUser();
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // To set the Orientation Lock
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ModalProgressHUD(
      inAsyncCall: isSpinning,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('My Profile'),
          ),
        ),
        drawer: NavDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: WidgetCircularAnimator(
                  innerIconsSize: 3,
                  outerIconsSize: 3,
                  innerAnimation: Curves.bounceIn,
                  outerAnimation: Curves.bounceIn,
                  innerColor: Colors.orangeAccent,
                  reverse: false,
                  outerColor: Colors.orangeAccent,
                  innerAnimationSeconds: 10,
                  outerAnimationSeconds: 10,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8.0),
                        // need to update this with proper crop system !!
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: img.image, // picked file
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            uploadWidget(),
            Expanded(
              child: Column(
                children: [
                  Container(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void uploadPic() async {
    setState(() {
      isSpinning = true;
    });
    var reference = fbs.ref().child('Profile Images').child(loggedUser.email);

    try {
      StorageUploadTask uploadTask = reference.putFile(imgFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String url = await storageTaskSnapshot.ref.getDownloadURL();
      await fs
          .collection('Users')
          .document(loggedUser.uid)
          .collection('Details')
          .document('Details')
          .setData({'Email': email, 'Name': name, 'Profile Image': url});
      getData();
    } catch (e) {
      Alert(
          context: context,
          title: 'Please try Again Something Bad Happened !!');
    }
    setState(() {
      showUpload = false;
      isSpinning = false;
    });
  }

  Widget uploadWidget() {
    if (showUpload) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
                child: InkWell(
                  splashColor: Colors.redAccent,
                  // ignore: missing_required_param, deprecated_member_use
                  child: FlatButton(
                    child: Text(
                      'Upload Profile Pic',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                  onTap: () {
                    // Do something here
                    uploadPic();
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Material(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
                child: InkWell(
                  splashColor: Colors.redAccent,
                  // ignore: missing_required_param, deprecated_member_use
                  child: FlatButton(
                    child: Text(
                      'Revert to Old Pic',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                  onTap: () {
                    // Do something here
                    revertPic();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else
      return Container();
  }

  void revertPic() {
    setState(() {
      img = oldPic;
      showUpload = false;
    });
  }

  // This is coming from flutter_image_compress package.
  // Used here instead of Asset Compression as it performs better
  // Asset compression is used as there that is appropriate
  Future<File> compressFile(File file) async {
    final filePath = file.absolute.path;
    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 60,
      );
      return result;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future getImage() async {
    oldPic = img;
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    setState(() async {
      if (pickedFile != null) {
        imageClicked = File(pickedFile.path);
        var compressedImage = await compressFile(imageClicked);
        setState(() {
          img = compressedImage == null
              ? Image.file(imageClicked)
              : Image.file(compressedImage);
          imgFile = compressedImage == null ? imageClicked : compressedImage;
          showUpload = true;
        });
      } else {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Image Selection Failed'),
          ),
        );
      }
    });
  }
}
