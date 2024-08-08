// import 'dart:async';
// import 'dart:io';
// import 'package:location/location.dart';
// import '../data/model/LocationModel.dart';

// class LocationService {
//   Location location = Location();

//   final StreamController<UserLocation> _locationStreamController =
//       StreamController<UserLocation>.broadcast(); // Menggunakan broadcast agar bisa memiliki beberapa listener
//   Stream<UserLocation> get locationStream => _locationStreamController.stream;

//   LocationService() {
//     checkPermissionAndRequestLocation();
//   }

//   void dispose() {
//     _locationStreamController.close();
//     location.changeSettings(
//         interval: 5000); // Set the location update interval back to default
//   }

//   void checkPermissionAndRequestLocation() async {
//     bool serviceEnabled = await location.serviceEnabled();

//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();

//       if (!serviceEnabled) {
//         print("Service disabled");
//         serviceEnabled = await location.requestService();
//       }
//     }

//     // Check if location permission is granted
//     PermissionStatus permissionStatus = await location.hasPermission();

//     while (permissionStatus == PermissionStatus.denied) {
//       permissionStatus = await location.requestPermission();
//     }

//     // Check if API level is 30 or higher and request background permission if needed
//     if (Platform.isAndroid && int.parse(Platform.version.split('.')[0]) >= 30) {
//       await location.requestPermission();
//     }

//     startLocationUpdates(); // Mulai mendapatkan lokasi saat izin diberikan
//   }

//   void startLocationUpdates() {
//     location.changeSettings(
//         interval: 5000); // Set the location update interval to 5000 milliseconds (5 seconds)

//     location.onLocationChanged.listen((locationData) {
//       _locationStreamController.add(UserLocation(
//           latitude: locationData.latitude!,
//           longitude: locationData.longitude!));
//     });
//   }
// }
