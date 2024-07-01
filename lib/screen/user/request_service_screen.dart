// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:angkutin/widget/ServiceCard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:angkutin/database/storage_service.dart';
import 'package:angkutin/provider/user/user_request_provider.dart';
import 'package:angkutin/screen/user/request_accepted_screen.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/SmallTextGrey.dart';

import '../../common/utils.dart';
import '../../data/model/UserModel.dart';
import '../../widget/CustomBasicTextField.dart';
import '../auth/map_screen.dart';

class RequestServiceScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-requestservice-screen';

  final User user;

  final int tipeAngkutan;
  // final String titleScreen;
  const RequestServiceScreen(
      {Key? key, required this.tipeAngkutan, required this.user
      // required this.titleScreen,
      })
      : super(key: key);

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  File? image;
  final ImageService imageService = ImageService();
  final TextEditingController _descController = TextEditingController();

  String? address;
  String? district;
  LatLng? coordinate;

  String? _urlPathImage;

  bool isLoading = false;

  // payment and type
  int? requestPrice;
  String? requestType;
  bool? isChecked = false;

  @override
  void initState() {
    super.initState();

    if (widget.tipeAngkutan == 1) {
      _urlPathImage = "carbage";
    } else {
      _urlPathImage = "report";
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestServiceProvider = Provider.of<UserRequestProvider>(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,

      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: mediaQueryHeight(context),
          child: ListView(
            children: [
              Text(
                  widget.tipeAngkutan == 1
                      ? "Permintaan Angkut Sampah"
                      : "Lapor Sampah Liar",
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
              widget.tipeAngkutan == 1
                  ? ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.moneyBill,
                        color: cGreenStrong,
                      ),
                      title: Text(
                        requestPrice != null
                            ? "Tipe $requestType | Rp. $requestPrice"
                            : "Pilih tipe angkutan",
                        style: const TextStyle(color: mainColor),
                      ),
                      onTap: () => _showPaymentTypeDialog(context),
                    )
                  : Container(),
        
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: cGreenStrong,
                ),
                title: Text(
                  coordinate != null ? "Oke !" : "Lokasinya dimana?",
                  style: const TextStyle(color: mainColor),
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
                  } else {
                    print(
                        "Koordinat null: ${coordinate?.toString() ?? 'Not selected'}");
                  }
                },
              ),
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.camera,
                  color: cGreenStrong,
                ),
                title: Text(
                  image != null ? "Oke !" : "Fotoin dong!",
                  style: const TextStyle(color: mainColor),
                ),
                onTap: () => _showImagePickerDialog(context),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomBasicTextField(descController: _descController),
              const SizedBox(
                height: 10,
              ),
                    widget.tipeAngkutan == 1
                  ? Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                              print(isChecked);
                            });
                          },
                        ),
                        Flexible(
                          child: Text(
                              'Saya memastikan bahwa ini bukanlah permintaan fiktif',
                              // maxLines: 2,
                              style: TextStyle(color: Colors.green[900])),
                        )
                      ],
                    )
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              isLoading == true
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      title: "Ajukan",
                      onPressed: () async {
                        // set loading
                        setState(() {
                          isLoading = true;
                        });

                        if (widget.tipeAngkutan == 1) {
                          if (coordinate == null ||
                              image == null ||
                              requestType == null ||
                              requestPrice == null ||
                              isChecked == false) {
                            setState(() {
                              isLoading = false;
                            });
                            showInfoSnackbar(context,
                                "Lengkapi data yang diperlukan untuk keperluan pengangkutan");
                            return;
                          }
                        } else if (widget.tipeAngkutan == 2) {
                          if (coordinate == null || image == null) {
                            setState(() {
                              isLoading = false;
                            });
                            showInfoSnackbar(context,
                                "Lengkapi data yang diperlukan untuk keperluan pengangkutan");
                            return;
                          }
                        }

                        final requestId = FirebaseFirestore.instance
                            .collection('requests')
                            .doc()
                            .id;
                        final now = Timestamp.now();

                        final storageService = StorageService();

                        final imgUrl = await storageService.uploadImage(
                            "requests", "$_urlPathImage/$requestId", image!);

                        final request = RequestService(
                            requestId: requestId,
                            senderEmail: widget.user.email!,
                            name: widget.user.name!,
                            date: now,
                            imageUrl: imgUrl,
                            description: _descController.text,
                            userLoc: GeoPoint(
                                coordinate!.latitude, coordinate!.longitude),
                            type: widget.tipeAngkutan,
                            isDelivered: false,
                            isAcceptByDriver: false,
                            isDone: false,
                            wilayah: extractLastPart(address!),
                            tipePermintaanAngkutan: widget.tipeAngkutan == 1
                                ? requestType
                                : "Laporan",
                            biayaPengangkutan:
                                widget.tipeAngkutan == 1 ? requestPrice : 0,
                            isPaying: widget.tipeAngkutan == 1 ? false : true);

                        // upload
                        await requestServiceProvider.createRequest(
                            path: _urlPathImage, requestService: request);

                        if (requestServiceProvider.state ==
                            ResultState.success) {
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushNamed(
                                context, RequestAcceptedScreen.ROUTE_NAME);
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          showInfoSnackbar(context,
                              "Gagal mengunggah data, coba lagi nanti");
                          print(
                              "Error gagal unggah permintaan : ${requestServiceProvider.errorMessage}");
                        }
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

  void _showPaymentTypeDialog(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                ServiceCard(
                    title: "Standar",
                    subtitle: "Jumlah sampah normal",
                    imageUrl:
                        'https://images.unsplash.com/photo-1718489211836-65a20ad6bd8d?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    trailing: _price("7 000"),
                    onPressed: () {
                      setState(() {
                        requestPrice = 7000;
                        requestType = "Standar";
                      });
                      Navigator.pop(context);
                    }),
                ServiceCard(
                    title: "Sedang",
                    subtitle: "Lebih banyak dari biasanya",
                    imageUrl:
                        'https://images.unsplash.com/photo-1718489211836-65a20ad6bd8d?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    trailing: _price("15 000"),
                    onPressed: () {
                      setState(() {
                        requestPrice = 15000;
                        requestType = "Sedang";
                      });
                      Navigator.pop(context);
                    }),
                ServiceCard(
                    title: "Banyak",
                    subtitle: "cocok utk selesai acara, perabotan, dll",
                    imageUrl:
                        'https://images.unsplash.com/photo-1718489211836-65a20ad6bd8d?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    trailing: _price("30 000"),
                    onPressed: () {
                      setState(() {
                        requestPrice = 30000;
                        requestType = "Banyak";
                      });
                      Navigator.pop(context);
                    }),
              ]));
        });
  }

  Text _price(String price) => Text(
        "Rp.\n$price,-",
        style: const TextStyle(fontSize: 14),
      );
}
