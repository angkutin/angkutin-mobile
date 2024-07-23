// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../common/constant.dart';

class TitleSection extends StatelessWidget {
  final String title;
  final Color? color;
  const TitleSection({
    Key? key,
    required this.title,
     this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color ?? mainColor),
    );
  }
}
