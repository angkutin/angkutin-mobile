// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/common/utils.dart';
import 'package:angkutin/widget/CustomListTile.dart';

import '../../common/constant.dart';
import '../../data/model/RequestModel.dart';
import '../../provider/monitor_provider.dart';
import '../../utils/route_helper.dart';
import '../../widget/RouteIndicator.dart';

class UserMonitorRequestScreen extends StatefulWidget {
  final int type;
  final String requestId;
  static const ROUTE_NAME = '/user-monitor-screen';

  const UserMonitorRequestScreen({
    Key? key,
    required this.type,
    required this.requestId,
  }) : super(key: key);

  @override
  State<UserMonitorRequestScreen> createState() =>
      _UserMonitorRequestScreenState();
}

class _UserMonitorRequestScreenState extends State<UserMonitorRequestScreen> {
  GoogleMapController? _mapController;
  // Position? _currentPosition;
  final LatLng _userLocation = const LatLng(
      3.575802989942146, 98.68665949148696); // mesjid raya untuk default saja
  Set<Marker> markers = {};
  Timer? _dataTimer;
  Set<Polyline> polylines = {};
  String routeStatus = '';

  @override
  void dispose() {
    _mapController?.dispose();
    _dataTimer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    markers.add(
      Marker(
        markerId: const MarkerId('userMarker'),
        position: _userLocation,
        draggable: true,
        infoWindow: const InfoWindow(title: 'Lokasi Permintaan'),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_userLocation),
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
    final monitorProvider =
        Provider.of<MonitorProvider>(context, listen: false);
    monitorProvider.getRequestDataStream(widget.type, widget.requestId);

    final snapshot = await monitorProvider.dataStream.first;
    final request = snapshot;
    final driverLocation = request.lokasiPetugas;
    final userLocation = request.userLoc;
    _fetchRoute(
      LatLng(userLocation.latitude, userLocation.longitude),
      LatLng(driverLocation!.latitude, driverLocation.longitude),
    );

    print("Load data dijalankan");
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

  @override
  Widget build(BuildContext context) {
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
            final userLocation = request.userLoc;

            // Update markers
            markers.clear();
            markers.add(
              Marker(
                markerId: const MarkerId('userMarker'),
                position: LatLng(userLocation.latitude, userLocation.longitude),
                draggable: true,
                infoWindow: const InfoWindow(title: 'Lokasi Anda'),
              ),
            );

            markers.add(
              Marker(
                  markerId: const MarkerId('driverMarker'),
                  position: LatLng(
                      driverLocation!.latitude, driverLocation.longitude),
                  infoWindow: const InfoWindow(title: 'Lokasi Driver'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen)),
            );
            return ListView(
              children: [
                driverLocation != null
                    ? SizedBox(
                        width: mediaQueryWidth(context),
                        height: mediaQueryHeight(context) / 2,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                userLocation.latitude, userLocation.longitude),
                            zoom: 18,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          markers: markers,
                          polylines: polylines,
                        ))
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                const Divider(
                  color: Colors.transparent,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      routeStatus.isNotEmpty
                          ? RouteIndicator(
                              color: Colors.red[900]!,
                              message: routeStatus,
                            )
                          : Container(),
                      const Text(
                        "Informasi pengangkutan",
                        style: text18cgs18,
                      ),
                      const Text(
                        "Petugas akan datang",
                        style: text14Black54,
                      ),
                    ],
                  ),
                ),
                CustomListTile(
                    title: "Nama petugas pengangkut",
                    value: "An. ${request.namaPetugas}"),
                CustomListTile(
                    title: "Waktu Permintaan",
                    value:
                        "${formatDate(request.date.toDate().toString())}, ${formatTime(request.date.toDate().toString())}"),
                CustomListTile(
                    title: "Catatan untuk petugas",
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
}
