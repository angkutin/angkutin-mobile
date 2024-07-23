import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<Map<String, String>> getAddressFromCoordinates(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return {
        "address": '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}',
        "district": placemark.subLocality ?? '',
        "coordinates": '$latitude, $longitude'
      };
    }
    return {};
  }
}
