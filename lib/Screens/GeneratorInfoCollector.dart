import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scan_n_select/ItemList.dart';
import 'package:scan_n_select/MaterialList.dart';
import 'package:scan_n_select/Screens/Generator.dart';

import '../Constants.dart';

class GeneratorInfoCollector extends StatefulWidget {
  static String id = 'Generator_Info_Collector_Screen';
  @override
  _GeneratorInfoCollectorState createState() => _GeneratorInfoCollectorState();
}

class _GeneratorInfoCollectorState extends State<GeneratorInfoCollector> {
  String selectedType = 'Pant';
  String selectedMaterial = 'Cotton';
  String itemColor;
  int colorDetected = Colors.white.value;
  String colorName = 'white';
  Image img = Image.asset('assets/default.png');
  File imgFile;
  List<DropdownMenuItem<String>> ls = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> material = <DropdownMenuItem<String>>[];
  TextEditingController ted = TextEditingController();

  @override
  void initState() {
    dragDownRegister();
    updatePaletteGenerator();
    super.initState();
  }

  void updatePaletteGenerator() async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      img.image,
    );
    setState(() {
      colorDetected = paletteGenerator.dominantColor.color.value;
    });
  }

  void dragDownRegister() {
    ls = [];
    for (String itemName in itemList) {
      DropdownMenuItem dm = DropdownMenuItem<String>(
        child: Text(itemName),
        value: itemName,
      );
      ls.add(dm);
    }
    material = [];
    for (String materialName in materialList) {
      DropdownMenuItem dm = DropdownMenuItem<String>(
        child: Text(materialName),
        value: materialName,
      );
      material.add(dm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: FlatButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Cloth Description'),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: Image(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: MediaQuery.of(context).size.height * 0.5,
                    image: img.image,
                  ),
                ),
              ),
            ),
            HeightSpacer(
              val: 20,
            ),
            Text(
              'Item Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            HeightSpacer(
              val: 10,
            ),
            getPicker(0),
            HeightSpacer(
              val: 20,
            ),
            Row(children: [
              Flexible(
                child: Text(
                  'Item Color',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 20,
                width: 20,
                color: Color(colorDetected),
              ),
            ]),
            HeightSpacer(
              val: 10,
            ),
            GestureDetector(
              onHorizontalDragDown: (dragDownDetails) {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                setState(() {
                  // This is used to remove focus from TextField !!!
                  FocusScope.of(context).unfocus();
                });
              },
              child: Container(
                child: TextField(
                  controller: ted,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    itemColor = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter Color Of Item', isCollapsed: true),
                ),
              ),
            ),
            HeightSpacer(
              val: 20,
            ),
            Text(
              'Material Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            HeightSpacer(val: 10),
            getPicker(1),
            HeightSpacer(
              val: 20,
            ),
            FlatButton(
              minWidth: MediaQuery.of(context).size.width * 0.85,
              color: Colors.blueAccent,
              child: Text('Generate QR'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                if (itemColor == null) {
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Generator(
                            selectedMaterial, selectedType, itemColor);
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext c) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      imgFile = image;
      img = Image.file(image);
    });
    await updatePaletteGenerator();
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      imgFile = image;
      img = Image.file(image);
    });
    await updatePaletteGenerator();
  }

  DropdownButton<String> getAndroidPicker(int level) {
    if (level == 0) {
      return DropdownButton<String>(
        isExpanded: true,
        value: selectedType,
        onChanged: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            selectedType = value;
          });
        },
        items: ls,
      );
    } else {
      return DropdownButton<String>(
        isExpanded: true,
        value: selectedMaterial,
        onChanged: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            selectedMaterial = value;
          });
        },
        items: material,
      );
    }
  }

  CupertinoPicker getIOSPicker(int level) {
    if (level == 0) {
      return CupertinoPicker(
        itemExtent: 32.0,
        onSelectedItemChanged: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            selectedType = itemList[value];
          });
        },
        children: ls,
      );
    } else {
      return CupertinoPicker(
        itemExtent: 32.0,
        onSelectedItemChanged: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            selectedMaterial = materialList[value];
          });
        },
        children: material,
      );
    }
  }

  Widget getPicker(int level) {
    if (Platform.isIOS)
      return getIOSPicker(level);
    else if (Platform.isAndroid) {
      return getAndroidPicker(level);
    } else {
      return Container();
    }
  }
}

class HeightSpacer extends StatelessWidget {
  final double val;
  HeightSpacer({this.val});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SizedBox(
        height: val,
      ),
    );
  }
}