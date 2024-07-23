// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/widget/CustomButton.dart';
import 'package:flutter/material.dart';

import '../common/constant.dart';
import '../common/utils.dart';
import '../data/model/RequestModel.dart';

class CarbageHaulCard extends StatelessWidget {
  final RequestService req;
  final VoidCallback onPressed;

  const CarbageHaulCard({
    Key? key,
    required this.req,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Waktu Pengajuan :", style: text14Black54),
                const Spacer(),
                Text(formatDate(req.date.toDate().toString()), style: text14Black54,),
                const SizedBox(width: 10,),
                Text(formatTime(req.date.toDate().toString()), style: text14Black54),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Status",
              style: text14Black54,
            ),
            Text(
              req.isAcceptByDriver ? "Diterima" : "Menunggu",
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: cGreenStrong),
            ),
           
            const SizedBox(
              height: 10,
            ),
            req.isAcceptByDriver
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
