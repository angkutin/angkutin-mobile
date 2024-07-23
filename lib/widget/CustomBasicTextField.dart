import 'package:flutter/material.dart';

import '../common/constant.dart';
import '../common/utils.dart';

class CustomBasicTextField extends StatelessWidget {
  const CustomBasicTextField({
    super.key,
    required TextEditingController descController,
  }) : _descController = descController;

  final TextEditingController _descController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: mediaQueryWidth(context),
      // height: height,
      decoration: BoxDecoration(
        border: Border.all(color: mainColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: _descController,
        textAlign: TextAlign.start,
        // maxLines: 1,
        maxLength: 250,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(8),
          hintText: "Masukkan Deskripsi",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
