import 'package:angkutin/common/constant.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String text;
  final double width;
  final double? height;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hintText;
  // final bool isRequired; // Added parameter for required/optional input

  const CustomTextField(
      {super.key,
      required this.text,
      required this.controller,
      required this.width,
      this.height,
      this.keyboardType,
      this.hintText
      // this.isRequired = false, // Default to optional
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: width,
            // height: height,
            decoration: BoxDecoration(
              border: Border.all(color: mainColor),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.start,
              maxLines: 1,
              keyboardType: keyboardType ?? TextInputType.text,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 14),
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14
                    // overflow: TextOverflow.ellipsis,
                    ),
                // labelStyle: TextStyle(
                //   color: Colors.grey,
                //   overflow: TextOverflow.ellipsis,
                // ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
