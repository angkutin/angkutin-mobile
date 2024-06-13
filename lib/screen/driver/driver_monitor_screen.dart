// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:angkutin/screen/driver/service/DriverLocationService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/monitor_provider.dart';
import 'package:angkutin/widget/CustomListTile.dart';

import '../../data/model/RequestModel.dart';
import '../../provider/driver/driver_service_provider.dart';

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
    _dataTimer = Timer.periodic(Duration(seconds: 5), (timer) {
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
            (marker) => marker.markerId == MarkerId('driverMarker'));
        markers.add(
          Marker(
            markerId: MarkerId('driverMarker'),
            position: _driverLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: 'Lokasi Petugas'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantau Permintaan"),
      ),
      body: Column(
        children: [
          Container(
            width: mediaQueryWidth(context),
            height: mediaQueryHeight(context) / 2,
            child: StreamBuilder<RequestService>(
              stream: Provider.of<MonitorProvider>(context).dataStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final request = snapshot.data!;
                  final driverLocation = request.lokasiPetugas;

                  if (driverLocation != null) {
                    final newLocation = LatLng(
                        driverLocation.latitude, driverLocation.longitude);
                    _updateDriverLocation(newLocation);
                  }
                }

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _driverLocation ??
                        LatLng(3.5649873243206964, 98.71563527362277),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: markers,
                );
              },
            ),
          ),
          CustomListTile(title: "Status", value: "Petugas dalam perjalanan"),
          CustomListTile(
              title: "Waktu Permintaan", value: "12 Mei 2024, 08:00 WIB"),
        ],
      ),
    );
  }
}
