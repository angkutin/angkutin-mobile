import 'package:angkutin/common/utils.dart';
import 'package:angkutin/screen/user/user_home_screen.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/SmallTextGrey.dart';
import 'package:angkutin/widget/TitleSectionBlue.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../common/AnimatedWidgetWrapper.dart';


class RequestAcceptedScreen extends StatelessWidget {
    static const ROUTE_NAME = '/user-requestacc';

  const RequestAcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
      ),
      
      body: SizedBox(
        width: mediaQueryWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lotties/succesfully-lottie.json'),
            const SizedBox(
              height: 40,
            ),
            const AnimatedWidgetWrapper(child:  TitleSection(title: "Permintaan Terkirim!")),
            const AnimatedWidgetWrapper(
              child:  SmallTextGrey(
                  description: "Selanjutnya tunggu update statusnya ya"),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                width: 100,
                child: CustomButton(title: "Oke !", onPressed: () => Navigator.pushReplacementNamed(context, UserHomeScreen.ROUTE_NAME))),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
