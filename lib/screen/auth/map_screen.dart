import 'dart:async';
import 'package:angkutin/common/geocoding_service.dart';
import 'package:angkutin/common/map_utils.dart';
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

  GeocodingService geoService = GeocodingService();
  // Variables to store address and district
  String _address = '';
  String _district = '';
  Map<String, String>? _userLocHumanReadable;
  // Marker position variable
  Set<Marker> markers = {};

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    _currentPosition = await getCurrentLocation();

    if (_currentPosition != null) {
      setState(() {
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
              });
            },
            infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          ),
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_userLocation!),
        );
      });
    }
  }

  // Method to handle confirmation button press
  void _onConfirmButtonPressed() async {
    try {
      if (_userLocation != null) {
        _userLocHumanReadable = await geoService.getAddressFromCoordinates(
            _userLocation!.latitude, _userLocation!.longitude);

        setState(() {
          // Assuming you have your logic to get address and district
          _address = _userLocHumanReadable?['address'] ?? '';
          _district = _userLocHumanReadable?['district'] ?? '';
        });

        // Navigate back to the previous screen with data
        Navigator.pop(context, {
          'coordinates':
              LatLng(_userLocation!.latitude, _userLocation!.longitude),
          'address': _address,
          'district': _district,
        });
      }
    } catch (e) {
      print(e);
    }
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
