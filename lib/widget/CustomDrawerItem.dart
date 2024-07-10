// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/constant.dart';
import 'package:flutter/material.dart';

class CustomDrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  const CustomDrawerItem({
    Key? key,
    required this.title,
    required this.onTap,
    this.trailing
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: basicTextStyleBlack),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
