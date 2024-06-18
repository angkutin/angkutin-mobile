import 'package:angkutin/common/utils.dart';
import 'package:angkutin/widget/CustomListTile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMonitorRequestScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-monitor-screen';

  const UserMonitorRequestScreen({super.key});

  @override
  State<UserMonitorRequestScreen> createState() =>
      _UserMonitorRequestScreenState();
}

class _UserMonitorRequestScreenState extends State<UserMonitorRequestScreen> {
  GoogleMapController? _mapController;
  // Position? _currentPosition;
  final LatLng _userLocation = const LatLng(3.575802989942146, 98.68665949148696);
  Set<Marker> markers = {};

  @override
  void dispose() {
    _mapController?.dispose();
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
        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_userLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantau Permintaan"),
      ),
      body: Column(
        children: [
          SizedBox(
            width: mediaQueryWidth(context),
            height: mediaQueryHeight(context) / 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation,
                zoom: 20,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: markers,
            ),),

            
            CustomListTile(title: "Status", value: "Petugas dalam perjalanan"),
            CustomListTile(title: "Waktu Permintaan", value: "12 Mei 2024, 08:00 WIB"),

                    ],
      ),
    );
  }
}
