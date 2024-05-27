// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../common/constant.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? paddingVertical;
  final double? paddingHorizontal;
  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.paddingVertical,
    this.paddingHorizontal
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding:  EdgeInsetsDirectional.symmetric(
                vertical: paddingVertical ?? 0,
                horizontal: paddingHorizontal ?? 0),
            backgroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ));
  }
}