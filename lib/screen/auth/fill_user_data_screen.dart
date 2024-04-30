import 'package:angkutin/common/utils.dart';
import 'package:angkutin/widget/CustomTextField.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 36,
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
                    print(screenIndex);
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
    return Column(
      children: [
        const TitleSectionBlue(
          title: 'Data 1/3 ',
        ),
        const Text(
          "Sepertinya anda baru disini! Isi data diri anda",
          textAlign: TextAlign.start,
        ),
        const SizedBox(
          height: 54,
        ),
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }

  Widget userDataScreen2() {
    return Column(
      children: [
        const TitleSectionBlue(
          title: 'Data 2/3 ',
        ),
        const Text(
          "Foto tampak depan rumah anda untuk kami kenali",
          textAlign: TextAlign.start,
        ),
        const SizedBox(
          height: 54,
        ),
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
                Image.network(dotenv.env['USER_HOME_URL_IMAGES']!),
                const Text("Tap untuk memilih gambar"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget userDataScreen3() {
    return Column(
      children: [
        const TitleSectionBlue(
          title: 'Data 3/3 ',
        ),
        const Text(
          "Foto tampak depan rumah anda untuk kami kenali",
          textAlign: TextAlign.start,
        ),
        const SizedBox(
          height: 54,
        ),
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
                Image.network(dotenv.env['USER_HOME_LOC_IMAGES']!),
                const Text("Tap untuk menentukan lokasi rumah ada"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
