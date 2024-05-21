import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class UserFillDataMapScreen extends StatefulWidget {
  @override
  _UserFillDataMapScreenState createState() => _UserFillDataMapScreenState();
}

class _UserFillDataMapScreenState extends State<UserFillDataMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _userLocation;

  // Variables to store address and district
  String _address = '';
  String _district = '';

  // Marker position variable
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Get current location
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        if (_currentPosition != null) {
          _userLocation = LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );

          markers.add(
            Marker(
              markerId: const MarkerId('userMarker'),
              position: _userLocation!,
              draggable: true,
              onDragEnd: (newPosition) {
                setState(() {
                  _userLocation = newPosition;
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(newPosition),
                  );
                  print("User Loc : $newPosition");
                });
              },
              infoWindow: const InfoWindow(title: 'Lokasi Anda'),
            ),
          );

          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_userLocation!),
          );
        }
      });
    } catch (e) {
      // Handle exception
      print('Error getting location: $e');
    }
  }

  // Method to handle confirmation button press
  void _onConfirmButtonPressed() {
    setState(() {
      // Assuming you have your logic to get address and district
      _address = 'Sample Address';
      _district = 'Sample District';
    });

    // Navigate back to the previous screen with data
    Navigator.pop(context, {
      'latitude': _userLocation?.latitude,
      'longitude': _userLocation?.longitude,
      'address': _address,
      'district': _district,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            onPressed: _onConfirmButtonPressed,
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 20,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: markers,
            ),
    );
  }
}
