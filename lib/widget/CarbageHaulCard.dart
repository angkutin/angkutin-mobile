// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/widget/CustomButton.dart';
import 'package:flutter/material.dart';

import '../common/constant.dart';
import '../common/utils.dart';

class CarbageHaulCard extends StatelessWidget {
  final bool status;
  final VoidCallback onPressed;

  const CarbageHaulCard({
    Key? key,
    required this.status,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: mediaQueryWidth(context),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cGreenSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permintaan Angkut',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: cGreenStrong),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Status",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black54),
            ),
            Text(
              status ? "Diterima" : "Menunggu",
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: cGreenStrong),
            ),
            const SizedBox(
              height: 10,
            ),
            status
                ? CustomButton(
                    title: "Pantau Permintaan",
                    paddingHorizontal: 16,
                    onPressed: onPressed)
                : Container()
          ],
        ),
      ),
    );
  }
}
