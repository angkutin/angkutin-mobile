// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/screen/driver/driver_gome_screen.dart';
import 'package:angkutin/screen/driver/service/DriverLocationService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/monitor_provider.dart';
import 'package:angkutin/widget/CustomListTile.dart';

import '../../data/model/RequestModel.dart';
import '../../provider/driver/driver_service_provider.dart';
import '../../widget/CustomButton.dart';

class DriverMonitorScreen extends StatefulWidget {
  final String requestId;
  final GeoPoint userLocation;
  static const ROUTE_NAME = '/driver-monitor-screen';

  const DriverMonitorScreen({
    Key? key,
    required this.requestId,
    required this.userLocation,
  }) : super(key: key);

  @override
  State<DriverMonitorScreen> createState() => _DriverMonitorScreenState();
}

class _DriverMonitorScreenState extends State<DriverMonitorScreen> {
  GoogleMapController? _mapController;
  // LatLng? _userLocation;
  LatLng? _driverLocation;
  LatLng? _previousDriverLocation;
  Set<Marker> markers = {};
  Timer? _dataTimer;

  double latitude = 0;
  double longitude = 0;

  GeoPoint? userLocationLatLng;

  @override
  void dispose() {
    _mapController?.dispose();
    _dataTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize the marker with the user's initial location
    markers.add(
      Marker(
        markerId: const MarkerId('userMarker'),
        position:
            LatLng(widget.userLocation.latitude, widget.userLocation.longitude),
        infoWindow: const InfoWindow(title: 'Lokasi Permintaan'),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDataUpdates();
    });
  }

  void _startDataUpdates() {
    _dataTimer?.cancel();
    _dataTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadData();
    });
  }

  _loadData() async {
// jalankan dulu tracking
    _loadAndUpdateDriverLocation();

// get data spesifik
    Provider.of<MonitorProvider>(context, listen: false)
        .getRequestDataStream(widget.requestId);
  }

  void _updateDriverLocation(LatLng newLocation) {
    if (_previousDriverLocation == newLocation) {
      return; // Avoid unnecessary updates
    }

    _previousDriverLocation = newLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _driverLocation = newLocation;
        markers.removeWhere(
            (marker) => marker.markerId == const MarkerId('driverMarker'));
        markers.add(
          Marker(
            markerId: const MarkerId('driverMarker'),
            position: _driverLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Lokasi Petugas'),
          ),
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_driverLocation!),
        );

        print("Driver location updated to: $_driverLocation");
      });
    });
  }

  _loadAndUpdateDriverLocation() async {
    LocationService locationService = LocationService();
    StreamSubscription<GeoPoint>? locationSubscription;

    locationSubscription =
        locationService.locationStream.listen((userLocation) {
      setState(() {
        latitude = userLocation.latitude;
        longitude = userLocation.longitude;

        userLocationLatLng = GeoPoint(latitude, longitude);

        _updateDriverLocationOnServer(
            "Bw2aq2Q0OYglg35x0Kfi", userLocationLatLng!);
      });
    });
  }

  _updateDriverLocationOnServer(String reqId, GeoPoint driverLoc) async {
    final driverServiceProv =
        Provider.of<DriverServiceProvider>(context, listen: false);
    await driverServiceProv.updateDriverLocation(reqId, driverLoc);

    // print("Lokasi diupdate pada __updateDriverLocation");
  }

  @override
  Widget build(BuildContext context) {
    final driverServiceProv = Provider.of<DriverServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantau Permintaan"),
      ),
      body: StreamBuilder<RequestService>(
        stream: Provider.of<MonitorProvider>(context).dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final request = snapshot.data!;
            final driverLocation = request.lokasiPetugas;

            if (driverLocation != null) {
              final newLocation =
                  LatLng(driverLocation.latitude, driverLocation.longitude);
              _updateDriverLocation(newLocation);
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      width: mediaQueryWidth(context),
                      height: mediaQueryHeight(context) / 2,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _driverLocation ??
                              const LatLng(3.5649873243206964,
                                  98.71563527362277), // initial data
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        markers: markers,
                      )),
                  Row(
                    children: [
                      const Spacer(),
                      driverServiceProv.finishIsLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              margin: const EdgeInsets.all(8),
                              width: 120,
                              child: CustomButton(
                                  title: "Sudah Diangkut",
                                  onPressed: () async {
                                    await driverServiceProv.finishUserRequest(
                                        request.requestId,
                                        request.senderEmail,
                                        request.idPetugas!);

                                    // balik ke home
                                    if (driverServiceProv.finishState ==
                                        ResultState.success) {
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          DriverHomeScreen.ROUTE_NAME
                                        );
                                      });
                                    } else {
                                      print("Gagal menyelesaikan orderan");
                                    }
                                  }),
                            ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  CustomListTile(
                      title: "Diajukan oleh", value: "An. ${request.name}"),
                  CustomListTile(
                      title: "Waktu Permintaan",
                      value:
                          "${formatDate(request.date.toDate().toString())}, ${formatTime(request.date.toDate().toString())}"),
                  CustomListTile(
                      title: "Deskripsi",
                      value: request.description! != ''
                          ? request.description!
                          : "-"),
                  Container(
                    width: mediaQueryWidth(context),
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    // decoration: containerBorderWithRadius.copyWith(
                    //     border: Border.all(color: softBlueColor)),
                    child: CachedNetworkImage(
                      imageUrl: request.imageUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
