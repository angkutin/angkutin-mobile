import 'package:flutter/material.dart';

import '../common/constant.dart';

class TitleSectionBlue extends StatelessWidget {
  final String title;
   const TitleSectionBlue({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: mainColor),
    );
  }
}
