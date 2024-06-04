import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly
      print('Location services are disabled.');
      return null;
    }

    // Check the current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if it is denied
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are still denied, handle accordingly
        print('Location permissions are denied.');
        return null;
      }
    }

    // If permissions are permanently denied, handle accordingly
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      print('Location permissions are permanently denied.');
      return null;
    }

    // When permissions are granted, get the current location
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return currentPosition;
  } catch (e) {
    // Handle exception
    print('Error getting location: $e');
    return null;
  }
}
