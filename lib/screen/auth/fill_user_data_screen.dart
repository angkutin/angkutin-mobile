import 'package:angkutin/common/utils.dart';
import 'package:angkutin/widget/CustomTextField.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../common/constant.dart';
import '../../widget/CustomButton.dart';
import '../../widget/TitleSectionBlue.dart';

class FillUserDataScreen extends StatefulWidget {
  const FillUserDataScreen({Key? key}) : super(key: key);

  @override
  State<FillUserDataScreen> createState() => _FillDataScreenState();
}

class _FillDataScreenState extends State<FillUserDataScreen> {
  int screenIndex = 0;
  List<String> subtitleContent = [
    "Sepertinya anda baru disini! Isi data diri anda",
    "Foto tampak depan rumah anda untuk kami kenali",
    "Pilih titik lokasi rumah anda di peta"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 36,
              ),
              Container(
                margin: const EdgeInsets.only(left: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                screenIndex > 0 ? screenIndex-- : null;
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                        TitleSection(
                          title: 'Data ${screenIndex + 1}/3 ',
                        ),
                      ],
                    ),
                    Text(
                      subtitleContent[screenIndex],
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 54,
              ),
              Expanded(
                child: IndexedStack(
                  index: screenIndex,
                  children: [
                    userDataScreen1(),
                    userDataScreen2(),
                    userDataScreen3(),
                  ],
                ),
              ),
              SizedBox(
                width: mediaQueryWidth(context),
                child: CustomButton(
                  title: 'Berikutnya',
                  onPressed: () {
                    setState(() {
                      screenIndex < 2 ? screenIndex++ : null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userDataScreen1() {
    return SizedBox(
      width: mediaQueryWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextField(
            text: "Nama Lengkap",
            controller: TextEditingController(),
            width: mediaQueryWidth(context) / 1.2,
          ),
          CustomTextField(
            text: "Nomor Aktif",
            controller: TextEditingController(),
            keyboardType: TextInputType.phone,
            width: mediaQueryWidth(context) / 1.2,
          ),
          CustomTextField(
            text: "Nomor Cadangan (opsional)",
            controller: TextEditingController(),
            keyboardType: TextInputType.phone,
            width: mediaQueryWidth(context) / 1.2,
          ),
        ],
      ),
    );
  }

  Widget userDataScreen2() {
    return SizedBox(
      width: mediaQueryWidth(context),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("Pilih gambar");
            },
            child: Container(
              width: mediaQueryWidth(context) / 1.2,
              height: mediaQueryWidth(context) / 1.2,
              decoration: BoxDecoration(
                border: Border.all(color: mainColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CachedNetworkImage(
                    imageUrl: dotenv.env['USER_HOME_URL_IMAGES']!,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  const Text("Tap untuk memilih gambar"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userDataScreen3() {
    return SizedBox(
      width: mediaQueryWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              print("Pilih lokasi");
            },
            child: Container(
              width: mediaQueryWidth(context) / 1.2,
              height: mediaQueryWidth(context) / 1.2,
              decoration: BoxDecoration(
                border: Border.all(color: mainColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CachedNetworkImage(
                    imageUrl: dotenv.env['USER_HOME_LOC_IMAGES']!, 
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  const Text("Tap untuk menentukan lokasi rumah ada"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
