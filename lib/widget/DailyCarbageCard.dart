// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/constant.dart';
import 'package:flutter/material.dart';

import '../common/utils.dart';
import 'SmallTextGrey.dart';

class DailyCarbageCard extends StatelessWidget {
  final String status;
  final String description;
  const DailyCarbageCard({
    Key? key,
    required this.status,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: mediaQueryWidth(context),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cBlueSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengangkutan Harian',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: secondaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  status,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: secondaryColor),
                ),
                SmallTextGrey(description: description),
              ],
            )
          ],
        ),
      ),
    );
  }
}
