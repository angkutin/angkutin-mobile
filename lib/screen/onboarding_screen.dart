import 'package:angkutin/common/constant.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../widget/TitleSectionBlue.dart';

class OnBoardingScreen extends StatefulWidget {
  static const ROUTE_NAME = '/onboarding';
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        bodyTextStyle: TextStyle(fontSize: 19),
        bodyPadding: EdgeInsets.all(16));
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        _pageContent(
            pageDecoration,
            dotenv.env['INTRODUCTION_1_IMAGES']!,
            "Selamat Datang di",
            "Angkutin",
            "Jelajahi berbagai fitur kami untuk memudahkan pengelolaan sampah rumah tangga Anda sehari-hari !"),
        _pageContent(
            pageDecoration,
            dotenv.env['INTRODUCTION_2_IMAGES']!,
            "Pilih Langganan",
            "Anda",
            "Temukan paket langganan yang tepat untuk kebutuhan sampah Anda!"),
        _pageContent(
            pageDecoration,
            dotenv.env['INTRODUCTION_3_IMAGES']!,
            "Ajukan Permintaan",
            "Sekarang",
            "Atasi sampah menumpuk, ajukan pengangkutan sekarang!"),
      ],
      onDone: () async {
        AuthenticationProvider authProvider = AuthenticationProvider();
        await authProvider.saveOnBoardingState(true);
        Navigator.pushReplacementNamed(context, LoginScreen.ROUTE_NAME);
      },
      // showSkipButton: true,
      showNextButton: false,
      showDoneButton: true,
      showBackButton: false,
      done: const Text("Mulai"),
      dotsDecorator: DotsDecorator(
          size: const Size(10, 10),
          color: Colors.grey,
          activeSize: const Size(22, 10),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
    );
  }

  PageViewModel _pageContent(PageDecoration pageDecoration, String image,
      String title, String subtitle, String descText) {
    return PageViewModel(
      bodyWidget: Column(
        children: [
          CachedNetworkImage(
            imageUrl: image,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          const SizedBox(
            height: 32,
          ),
          TitleSection(
            title: title,
            color: blackColor,
          ),
          TitleSection(title: subtitle),
          const SizedBox(
            height: 16,
          ),
          Text(
            descText,
            textAlign: TextAlign.center,
          )
        ],
      ),
      title: "",
      decoration: pageDecoration,
    );
  }
}
