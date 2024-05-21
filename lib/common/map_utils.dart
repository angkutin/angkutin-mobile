import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  // Get current location
  try {
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
