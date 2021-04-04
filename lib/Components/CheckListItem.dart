import 'package:flutter/material.dart';

List<String> li;
var icon;

class CheckListItem extends StatefulWidget {
  CheckListItem(lis, icons) {
    li = lis;
    icon = icons;
  }

  @override
  _CheckListItemState createState() => _CheckListItemState();
}

class _CheckListItemState extends State<CheckListItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(
          width: 10,
        ),
        Text(
          li[0],
          style: TextStyle(fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}
