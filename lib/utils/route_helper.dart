import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteHelper {
  static Future<Map<String, dynamic>> fetchRoute(LatLng origin, LatLng destination) async {
    final String apiKey = dotenv.env['OPENROUTESERVICE_API_KEY']!;
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      return {
        'status': 'success',
        'polylines': _createPolylines(coordinates)
      };
    } else {
      return {
        'status': 'error',
        'message': 'Failed to fetch directions: ${response.body}'
      };
    }
  }

  static List<LatLng> _createPolylines(List<dynamic> coordinates) {
    List<LatLng> polylineCoordinates = [];
    for (var coordinate in coordinates) {
      polylineCoordinates.add(LatLng(coordinate[1], coordinate[0]));
    }
    return polylineCoordinates;
  }
}
