import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/screen/driver/driver_gome_screen.dart';
import 'package:angkutin/screen/driver/service/DriverLocationService.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/monitor_provider.dart';
import 'package:angkutin/widget/CustomListTile.dart';
import '../../data/model/RequestModel.dart';
import '../../provider/driver/driver_service_provider.dart';
import '../../widget/CustomButton.dart';

class DriverMonitorScreen extends StatefulWidget {
  final int type;
  final String requestId;
  final GeoPoint userLocation;
  static const ROUTE_NAME = '/driver-monitor-screen';

  const DriverMonitorScreen({
    Key? key,
    required this.type,
    required this.requestId,
    required this.userLocation,
  }) : super(key: key);

  @override
  State<DriverMonitorScreen> createState() => _DriverMonitorScreenState();
}

class _DriverMonitorScreenState extends State<DriverMonitorScreen> {
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  LatLng? _previousDriverLocation;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Timer? _dataTimer;
  StreamSubscription<GeoPoint>? locationSubscription;

  double latitude = 0;
  double longitude = 0;
  GeoPoint? userLocationLatLng;

  @override
  void dispose() {
    _mapController?.dispose();
    _dataTimer?.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    markers.add(
      Marker(
        markerId: const MarkerId('userMarker'),
        position: LatLng(widget.userLocation.latitude, widget.userLocation.longitude),
        infoWindow: const InfoWindow(title: 'Lokasi Permintaan'),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDataUpdates();
    });
  }

  void _startDataUpdates() {
    _dataTimer?.cancel();
    _dataTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadData();
    });
  }

  _loadData() async {
    _loadAndUpdateDriverLocation();
    Provider.of<MonitorProvider>(context, listen: false)
        .getRequestDataStream(widget.type, widget.requestId);
  }

  void _updateDriverLocation(LatLng newLocation) {
    if (_previousDriverLocation == newLocation) {
      return; // Avoid unnecessary updates
    }

    _previousDriverLocation = newLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _driverLocation = newLocation;
        markers.removeWhere((marker) => marker.markerId == const MarkerId('driverMarker'));
        markers.add(
          Marker(
            markerId: const MarkerId('driverMarker'),
            position: _driverLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Lokasi Petugas'),
          ),
        );

        _mapController?.animateCamera(CameraUpdate.newLatLng(_driverLocation!));

        _fetchRoute(LatLng(widget.userLocation.latitude, widget.userLocation.longitude), _driverLocation!);
      });
    });
  }

  _loadAndUpdateDriverLocation() async {
    LocationService locationService = LocationService();

    locationSubscription = locationService.locationStream.listen((userLocation) {
      setState(() {
        latitude = userLocation.latitude;
        longitude = userLocation.longitude;

        userLocationLatLng = GeoPoint(latitude, longitude);
      });
    });
  }

  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    final String apiKey = dotenv.env['OPENROUTESERVICE_API_KEY']!;
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      _createPolylines(coordinates);
    } else {
      print('Failed to fetch directions: ${response.body}');
    }
  }

  void _createPolylines(List<dynamic> coordinates) {
    List<LatLng> polylineCoordinates = [];
    for (var coordinate in coordinates) {
      polylineCoordinates.add(LatLng(coordinate[1], coordinate[0]));
    }

    setState(() {
      polylines.clear();
      polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId("poly"),
        color: Colors.blue,
        points: polylineCoordinates,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final driverServiceProv = Provider.of<DriverServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantau Permintaan"),
      ),
      body: StreamBuilder<RequestService>(
        stream: Provider.of<MonitorProvider>(context).dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final request = snapshot.data!;
            final driverLocation = request.lokasiPetugas;

            if (driverLocation != null) {
              final newLocation =
                  LatLng(driverLocation.latitude, driverLocation.longitude);
              _updateDriverLocation(newLocation);
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      width: mediaQueryWidth(context),
                      height: mediaQueryHeight(context) / 2,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _driverLocation ??
                              const LatLng(3.5649873243206964, 98.71563527362277), // initial data
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        markers: markers,
                        polylines: polylines,
                      )),
                  Row(
                    children: [
                      const Spacer(),
                      driverServiceProv.finishIsLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              margin: const EdgeInsets.all(8),
                              width: 120,
                              child: CustomButton(
                                  title: "Sudah Diangkut",
                                  onPressed: () async {
                                    await driverServiceProv.finishUserRequest(
                                        request.requestId,
                                        request.senderEmail,
                                        request.idPetugas!);

                                    // balik ke home
                                    if (driverServiceProv.finishState == ResultState.success) {
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          DriverHomeScreen.ROUTE_NAME
                                        );
                                      });
                                    } else {
                                      print("Gagal menyelesaikan orderan");
                                    }
                                  }),
                            ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  CustomListTile(
                      title: "Diajukan oleh", value: "An. ${request.name}"),
                  CustomListTile(
                      title: "Waktu Permintaan",
                      value: "${formatDate(request.date.toDate().toString())}, ${formatTime(request.date.toDate().toString())}"),
                  CustomListTile(
                      title: "Deskripsi",
                      value: request.description! != '' ? request.description! : "-"),
                  Container(
                    width: mediaQueryWidth(context),
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: CachedNetworkImage(
                      imageUrl: request.imageUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
