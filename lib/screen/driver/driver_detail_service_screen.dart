import 'dart:convert';

import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/driver/driver_service_provider.dart';
import 'package:angkutin/screen/driver/driver_gome_screen.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/CustomListTile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:provider/provider.dart';

import '../../data/model/UserModel.dart';
import '../../provider/auth/auth_provider.dart';

class DriverDetailServiceScreen extends StatefulWidget {
  final RequestService serviceData;
  final GeoPoint driverLocation;
  static const ROUTE_NAME = '/driver-detailservice-screen';

  const DriverDetailServiceScreen({
    Key? key,
    required this.serviceData,
    required this.driverLocation,
  }) : super(key: key);

  @override
  State<DriverDetailServiceScreen> createState() =>
      _DriverDetailServiceScreenState();
}

class _DriverDetailServiceScreenState extends State<DriverDetailServiceScreen> {
  GoogleMapController? _mapController;
  Set<Marker> markers = {};
  User? _user;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _addDriverMarker();
    _loadData();
  }

  _loadData() async {
    final prefs =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .readUserDataLocally();
    if (prefs != null) {
      setState(() {
        _user = User.fromJson(jsonDecode(prefs));
      });
    }
  }

  Future<void> _addDriverMarker() async {
    var driverLoc = widget.driverLocation;
    var latitude = driverLoc.latitude;
    var longitude = driverLoc.longitude;
    print("Lokasi Driver ${driverLoc.latitude}, ${driverLoc.longitude}");

    markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: LatLng(
          latitude,
          longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: "Lokasi Kamu",
        ),
      ),
    );
  }

  void _showMarkersAndAdjustCamera() {
    var requestData = widget.serviceData;
    var driverLoc = widget.driverLocation;

    var bounds = LatLngBounds(
      southwest: LatLng(
        requestData.userLoc.latitude < driverLoc.latitude
            ? requestData.userLoc.latitude
            : driverLoc.latitude,
        requestData.userLoc.longitude < driverLoc.longitude
            ? requestData.userLoc.longitude
            : driverLoc.longitude,
      ),
      northeast: LatLng(
        requestData.userLoc.latitude > driverLoc.latitude
            ? requestData.userLoc.latitude
            : driverLoc.latitude,
        requestData.userLoc.longitude > driverLoc.longitude
            ? requestData.userLoc.longitude
            : driverLoc.longitude,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    var requestData = widget.serviceData;
    final driverServiceProv = Provider.of<DriverServiceProvider>(context);

    return Scaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: mediaQueryWidth(context),
                height: mediaQueryHeight(context) / 2,
                color: cGreenSofter,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      requestData.userLoc.latitude,
                      requestData.userLoc.longitude,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;

                    setState(() {
                      markers.add(
                        Marker(
                          markerId: const MarkerId('sender_location'),
                          position: LatLng(
                            requestData.userLoc.latitude,
                            requestData.userLoc.longitude,
                          ),
                          infoWindow: InfoWindow(
                            title: requestData.name,
                          ),
                        ),
                      );

                      // Call the function to adjust the camera
                      _showMarkersAndAdjustCamera();
                    });
                  },
                  markers: markers,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                ),
              ),

              const SizedBox(
                height: 5,
              ),
              // button
              Container(
                // color: cGreenSoft,
                decoration: BoxDecoration(
                  color: cGreenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Informasi Detail Layanan",
                        style: basicTextStyleBlack.copyWith(fontSize: 16),
                      ),
                      driverServiceProv.servIsLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              margin: const EdgeInsets.all(8),
                              width: 120,
                              child: CustomButton(
                                  title: "Ambil",
                                  onPressed: () async {
                                    if (_user != null) {
                                      await driverServiceProv.acceptUserRequest(
                                        requestData.type,
                                          requestData.requestId,
                                          _user!.name!,
                                          _user!.email!,
                                          widget.driverLocation);
                                    } else {
                                      print("user null");
                                    }

                                    if (driverServiceProv.servState ==
                                        ResultState.success) {
                                      Navigator.pushReplacementNamed(
                                          context, DriverHomeScreen.ROUTE_NAME);
                                    }
                                  }),
                            ),
                    ]),
              ),
              CustomListTile(
                  title: "Pengirim", value: "An. ${requestData.name}"),
              CustomListTile(
                  title: "Deskripsi",
                  value: requestData.description! != ''
                      ? requestData.description!
                      : "-"),
              CustomListTile(
                  title: "Waktu Permintaan",
                  value:
                      "${formatDate(requestData.date.toDate().toString())} | ${formatTime(requestData.date.toDate().toString())}"),
              CustomListTile(title: "Wilayah", value: requestData.wilayah),
              CustomListTile(
                  title: "Tipe Layanan",
                  value: requestData.type == 1
                      ? "Permintaan Pengangkutan Sampah"
                      : "Laporan Timbunan Sampah"),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 200,
                padding: const EdgeInsets.all(16),
                decoration: containerBorderWithRadius.copyWith(
                    border: Border.all(color: softBlueColor)),
                child: CachedNetworkImage(
                  imageUrl: requestData.imageUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),

              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
