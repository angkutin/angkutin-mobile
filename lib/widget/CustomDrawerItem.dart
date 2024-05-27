// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/constant.dart';
import 'package:flutter/material.dart';

class CustomDrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CustomDrawerItem({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: basicTextStyleBlack),
      onTap: onTap,
    );
  }
}
