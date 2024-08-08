import 'dart:convert';
import 'dart:io';

import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/upload_provider.dart';
import 'package:angkutin/screen/user/user_home_screen.dart';
import 'package:angkutin/widget/CustomTextField.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/constant.dart';
import '../../widget/CustomButton.dart';
import '../../widget/TitleSectionBlue.dart';
import 'map_screen.dart';
import '../../data/model/UserModel.dart' as userModel;

class FillUserDataScreen extends StatefulWidget {
  static const ROUTE_NAME = '/fill-data';
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

  // Fill data 1
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _activeNumberController = TextEditingController();
  final TextEditingController _optNumberController = TextEditingController();

  // Fill data 2
  File? image;
  final ImageService imageService = ImageService();

  // Fill data 3
  String? address;
  String? district;
  LatLng? coordinate;
  String _locationMessage = "Tap untuk menentukan lokasi rumah ada";

// user data local

  userModel.User? _user;

  @override
  void dispose() {
    _fullNameController.dispose();
    _activeNumberController.dispose();
    _optNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  _loadData() async {
    final prefs =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .readUserDataLocally();
    if (prefs != null) {
      setState(() {
        _user = userModel.User.fromJson(jsonDecode(prefs));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = Provider.of<UploadProvider>(context, listen: true);

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
              uploadProvider.isLoading == true
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: mediaQueryWidth(context),
                      child: CustomButton(
                        title: 'Berikutnya',
                        onPressed: _nextScreen,
                      )),
            ],
          ),
        ),
      ),
    );
  }

  void _nextScreen() async {
    String? errorMessage;

    if (screenIndex == 0) {
      if (_fullNameController.text.isEmpty ||
          _activeNumberController.text.isEmpty) {
        errorMessage =
            "Nama Lengkap atau Nomor Telepon Aktif tidak boleh kosong";
      }
    } else if (screenIndex == 1) {
      if (image == null) {
        errorMessage =
            "Harap masukkan foto depan rumah Anda agar mudah dikenali";
      }
    } else if (screenIndex == 2) {
      if (coordinate != null && address != null && district != null) {
        // Notice the change here
        final uploadProvider =
            Provider.of<UploadProvider>(context, listen: false);
        final authProvider =
            Provider.of<AuthenticationProvider>(context, listen: false);

        await uploadProvider.uploadDataRegister(
            docId: _user!.email!,
            fullName: _fullNameController.text,
            isDaily: false,
            address: extractLastPart(address!),
            activePhoneNumber: int.parse(_activeNumberController.text),
            optionalPhoneNumber: _optNumberController.text.isNotEmpty
                ? int.parse(_optNumberController.text)
                : null,
            image: image!,
            latitude: coordinate!.latitude,
            longitude: coordinate!.longitude,
            services: [] );

        if (uploadProvider.state == ResultState.success) {
          if (_user != null) {
            userModel.User updatedUser = userModel.User(
                email: _user!.email,
                name: _user!.name,
                role: _user!.role,
                fullName: _fullNameController.text.isNotEmpty
                    ? _fullNameController.text
                    : _user!.fullName,
                isDaily: null,
                address: address,
                activePhoneNumber: int.parse(_activeNumberController.text),
                optionalPhoneNumber: _optNumberController.text.isNotEmpty
                    ? int.parse(_optNumberController.text)
                    : null,
                latitude: coordinate!.latitude,
                longitude: coordinate!.longitude,
                imageUrl: uploadProvider.imageUrl,
                services: []);

            authProvider.saveUserDataLocally(updatedUser);
            authProvider.saveLoginState(true);
          }
          showInfoSnackbar(context, "Berhasil mengunggah data");
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, UserHomeScreen.ROUTE_NAME);
          });
        } else {
          showInfoSnackbar(context, "Gagal mengunggah data, coba lagi nanti");
        }
      }
      errorMessage = "Belum diatur";
    }

    if (errorMessage != null) {
      showInfoSnackbar(context, errorMessage);
    } else {
      setState(() {
        screenIndex++;
      });
    }
  }

  Widget userDataScreen1() {
    return SizedBox(
      width: mediaQueryWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextField(
            text: "Nama Lengkap",
            controller: _fullNameController,
            width: mediaQueryWidth(context) / 1.2,
          ),
          CustomTextField(
            text: "Nomor Aktif",
            controller: _activeNumberController,
            keyboardType: TextInputType.phone,
            width: mediaQueryWidth(context) / 1.2,
          ),
          CustomTextField(
            text: "Nomor Cadangan (opsional)",
            controller: _optNumberController,
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
            onTap: () async {
              await imageService.pickImageFromGallery();
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  image = imageService.image;
                });
              });
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
                  SizedBox(
                    height: 200,
                    child: image != null
                        ? Image.file(
                            image!,
                            fit: BoxFit.fill,
                          )
                        : CachedNetworkImage(
                            imageUrl: dotenv.env['USER_HOME_URL_IMAGES']!,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
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
    void _openMapScreen() async {
      final Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserFillDataMapScreen(),
        ),
      );

      if (result != null) {
        setState(() {
          coordinate = result['coordinates'];
          address = result['address'];
          district = result['district'];
          _locationMessage = "${coordinate?.latitude}, ${coordinate?.longitude}\n${extractLastPart(address!)}";
        });

      } 
    }

    return SizedBox(
      width: mediaQueryWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _openMapScreen,
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
                   Text(_locationMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
