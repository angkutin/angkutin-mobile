import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';


class LocationService {
  Location location = Location();

  final StreamController<GeoPoint> _locationStreamController =
      StreamController<GeoPoint>();
  Stream<GeoPoint> get locationStream => _locationStreamController.stream;

  LocationService() {
    checkPermissionAndRequestLocation();
    startLocationUpdates();
  }

  void dispose() {
    _locationStreamController.close();
    location.changeSettings(
        interval: 5000); // Set the location update interval back to default
  }

  void checkPermissionAndRequestLocation() async {
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
    }

    // Check if location permission is granted
    PermissionStatus permissionStatus = await location.hasPermission();

    while (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }

    // Check if API level is 30 or higher and request background permission if needed
    if (Platform.isAndroid && int.parse(Platform.version.split('.')[0]) >= 30) {
      await location.requestPermission();
    }
  }

  void startLocationUpdates() {
    location.changeSettings(
        interval:
            5000); // Set the location update interval to 3000 milliseconds (3 seconds)

    location.onLocationChanged.listen((locationData) {
      _locationStreamController.add(
          GeoPoint(locationData.latitude!, locationData.longitude!)
          );
    });
  }
}