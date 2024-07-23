import 'package:flutter/material.dart';

import '../common/constant.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String value;
  final Widget? trailing;
  const CustomListTile(
      {Key? key, required this.title, required this.value, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: basicTextStyleBlack.copyWith(
            color: blackColor,
          )),
      subtitle: Text(value,
          style: basicTextStyleBlack.copyWith(color: softBlueColor)),
      trailing: trailing,
    );
  }
}