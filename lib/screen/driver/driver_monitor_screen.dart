import 'dart:async';

import 'package:angkutin/screen/driver/driver_gome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/screen/driver/service/DriverLocationService.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/monitor_provider.dart';
import 'package:angkutin/widget/CustomListTile.dart';
import '../../common/constant.dart';
import '../../data/model/RequestModel.dart';
import '../../provider/driver/driver_service_provider.dart';
import '../../utils/route_helper.dart';
import '../../widget/CustomButton.dart';
import '../../widget/RouteIndicator.dart';

class DriverMonitorScreen extends StatefulWidget {
  final int type;
  final String requestId;
  final GeoPoint userLocation;
  static const ROUTE_NAME = '/driver-monitor-screen';

  const DriverMonitorScreen({
    Key? key,
    required this.type,
    required this.requestId,
    required this.userLocation,
  }) : super(key: key);

  @override
  State<DriverMonitorScreen> createState() => _DriverMonitorScreenState();
}

class _DriverMonitorScreenState extends State<DriverMonitorScreen> {
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  LatLng? _previousDriverLocation;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Timer? _dataTimer;
  StreamSubscription<GeoPoint>? locationSubscription;

  double latitude = 0;
  double longitude = 0;
  GeoPoint? userLocationLatLng;
  String routeStatus = '';

  @override
  void dispose() {
    _mapController?.dispose();
    _dataTimer?.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
    _loadAndUpdateDriverLocation();
    Provider.of<MonitorProvider>(context, listen: false)
        .getRequestDataStream(widget.type, widget.requestId);
  }

  void _updateDriverLocation(LatLng newLocation) {
    if (_previousDriverLocation == newLocation) {
      return; // Avoid unnecessary updates
    }

    _previousDriverLocation = newLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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

          _mapController
              ?.animateCamera(CameraUpdate.newLatLng(_driverLocation!));
        });
      }

      final userLoc = widget.userLocation;
      _fetchRoute(
          LatLng(userLoc.latitude, userLoc.longitude), _driverLocation!);
    });
  }

  Future<void> _fetchRoute(LatLng userLocation, LatLng driverLocation) async {
    if (mounted) {
      setState(() {
        routeStatus = '';
      });
    }

    final result = await RouteHelper.fetchRoute(userLocation, driverLocation);
    if (result['status'] == 'success') {
      if (mounted) {
        setState(() {
          polylines.clear();
          polylines.add(Polyline(
            width: 5,
            polylineId: const PolylineId("poly"),
            color: Colors.blue,
            points: result['polylines'],
          ));
          routeStatus = '';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          routeStatus = 'Ada masalah dalam menampilkan rute';
        });
      }
    }
  }

  _loadAndUpdateDriverLocation() async {
    LocationService locationService = LocationService();

    locationSubscription =
        locationService.locationStream.listen((userLocation) {
      if (mounted) {
        setState(() {
          latitude = userLocation.latitude;
          longitude = userLocation.longitude;

          userLocationLatLng = GeoPoint(latitude, longitude);
        });
      }
    });
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
            return ListView(
              children: [
                SizedBox(
                    width: mediaQueryWidth(context),
                    height: mediaQueryHeight(context) / 2,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _driverLocation ??
                            const LatLng(3.5649873243206964,
                                98.71563527362277), // initial data
                        zoom: 18,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      markers: markers,
                      polylines: polylines,
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
                                onPressed: () {
                                  _showFinishServiceDialog(context, widget.type,
                                      driverServiceProv, request);
                                }),
                          ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
                routeStatus.isNotEmpty
                    ? RouteIndicator(
                        color: Colors.red[900]!,
                        message: routeStatus,
                      )
                    : Container(),
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
                const SizedBox(
                  height: 20,
                )
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }

void _showFinishServiceDialog(BuildContext context, int type,
    DriverServiceProvider serviceProvider, RequestService service) {
  bool isChecked = false;
  bool error = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text(
              "Konfirmasi sampah sudah diangkut",
              style: basicTextStyleBlack,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Apakah kamu yakin ingin menyelesaikan layanan?",
                  ),
                  if (type == 1)
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        const Flexible(
                          child: Text(
                            'Saya memastikan bahwa semua sudah sesuai, termasuk biaya yang telah disepakati (tidak termasuk tips). Permintaan pengangkutan sampah telah selesai dan semua tugas telah dilakukan dengan baik.',
                            style: TextStyle(color: mainColor),
                          ),
                        ),
                      ],
                    ),
                  if (error)
                    const Text(
                      "Periksa kembali konfirmasi pengangkutan",
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              if (serviceProvider.finishIsLoading == true)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                SizedBox(
                  width: 120,
                  child: CustomButton(
                    title: "Selesaikan",
                    onPressed: () async {
                      if (type == 1 && !isChecked) {
                        setState(() {
                          error = true;
                        });
                        return;
                      }
                      
                      await serviceProvider.finishUserRequest(
                        service.type,
                        service.requestId,
                        service.senderEmail,
                        service.idPetugas!,
                      );

                      if (serviceProvider.finishState == ResultState.success) {
                        Navigator.pushReplacementNamed(
                          context, DriverHomeScreen.ROUTE_NAME);
                      } else {
                        print("Gagal menyelesaikan orderan");
                      }
                    },
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

}
