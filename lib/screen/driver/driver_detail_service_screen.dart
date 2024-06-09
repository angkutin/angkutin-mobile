import 'package:angkutin/common/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/data/model/RequestModel.dart';

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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _addDriverMarker();
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
        requestData.userLoc.latitude < driverLoc.latitude ? requestData.userLoc.latitude : driverLoc.latitude,
        requestData.userLoc.longitude < driverLoc.longitude ? requestData.userLoc.longitude : driverLoc.longitude,
      ),
      northeast: LatLng(
        requestData.userLoc.latitude > driverLoc.latitude ? requestData.userLoc.latitude : driverLoc.latitude,
        requestData.userLoc.longitude > driverLoc.longitude ? requestData.userLoc.longitude : driverLoc.longitude,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    var requestData = widget.serviceData;

    return Scaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: mediaQueryWidth(context),
              height: mediaQueryHeight(context) / 2,
              color: blackColor,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    requestData.userLoc.latitude,
                    requestData.userLoc.longitude,
                  ),
                  zoom: 18,
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
                    print("Lokasi Sender ${requestData.userLoc.latitude}");

                    // Call the function to adjust the camera
                    _showMarkersAndAdjustCamera();
                  });
                },
                markers: markers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
