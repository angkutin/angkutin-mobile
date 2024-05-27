// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/SmallTextGrey.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/utils.dart';
import '../../widget/CustomBasicTextField.dart';
import '../auth/map_screen.dart';

class RequestServiceScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-requestservice-screen';

  final String titleScreen;
  const RequestServiceScreen({
    Key? key,
    required this.titleScreen,
  }) : super(key: key);

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  File? image;
  final ImageService imageService = ImageService();
  TextEditingController _descController = TextEditingController();

  String? address;
  String? district;
  LatLng? coordinate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,

      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: mediaQueryHeight(context),
          child: ListView(
            children: [
              Text(widget.titleScreen,
                  style: basicTextStyleBlack.copyWith(fontSize: 18)),
              const SmallTextGrey(
                description: "Isi informasi yang diperlukan",
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: 200,
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.contain,
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
              ),
              const Divider(),
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: cGreenStrong,
                ),
                title: const Text(
                  "Lokasinya dimana?",
                  style: TextStyle(color: mainColor),
                ),
                onTap: () async {
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
                    });
                    print(
                        "Koordinat : ${coordinate?.toString() ?? 'Not selected'}");
                    print('Address: ${address ?? 'Not selected'}');
                    print('Kecamatan: ${district ?? 'Not selected'}');
                  } else {
                    print(
                        "Koordinat null: ${coordinate?.toString() ?? 'Not selected'}");
                    print('Address: ${address ?? 'Not selected'}');
                    print('Kecamatan: ${district ?? 'Not selected'}');
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.trash,
                  color: cGreenStrong,
                ),
                title: const Text(
                  "Fotoin dong!",
                  style: TextStyle(color: mainColor),
                ),
                onTap: () => _showImagePickerDialog(context),
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              CustomBasicTextField(descController: _descController),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                  title: "Ajukan",
                  onPressed: () {
                    print("Ajukan");
                  })
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            'Lampirkan foto sampah agar mudah dikenali petugas.',
            style: basicTextStyleBlack,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await imageService.pickImageFromCamera();
                setState(() {
                  image = imageService.image;
                  Navigator.pop(context);
                });
                // Future.delayed(const Duration(milliseconds: 500), () {

                // });
              },
              child: const Text('Melalui Kamera'),
            ),
            TextButton(
              onPressed: () async {
                await imageService.pickImageFromGallery();
                setState(() {
                  image = imageService.image;
                  Navigator.pop(context);
                });
              },
              child: const Text('Pilih dari Galeri'),
            ),
          ],
        );
      },
    );
  }
}
