import 'package:angkutin/common/utils.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/SmallTextGrey.dart';
import 'package:angkutin/widget/TitleSectionBlue.dart';
import 'package:flutter/material.dart';

class RequestAcceptedScreen extends StatelessWidget {
  const RequestAcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: mediaQueryWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/successfuly_image.png"),
            const SizedBox(
              height: 40,
            ),
            const TitleSection(title: "Permintaan Terkirim!"),
            const SmallTextGrey(
                description: "Selanjutnya tunggu update status permintaan ya"),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                width: 100,
                child: CustomButton(title: "Oke !", onPressed: () {})),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
