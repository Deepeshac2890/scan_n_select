import 'package:flutter/material.dart';
import 'package:scan_n_select/Class/CityItem.dart';

class CustomCityListItem extends StatefulWidget {
  @override
  _CustomCityListItemState createState() => _CustomCityListItemState();
}

class _CustomCityListItemState extends State<CustomCityListItem> {
  CityItem ci;

  TextEditingController ti = TextEditingController();

  TextEditingController getController() {
    return ti;
  }

  @override
  void initState() {
    ci = new CityItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.circle),
      title: TextField(
        controller: ti,
        onChanged: (value) {
          ci.updateCityName(value);
          print(ci.cityName);
        },
      ),
    );
  }
}
