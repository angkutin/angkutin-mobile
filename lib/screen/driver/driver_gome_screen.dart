import 'dart:async';
import 'dart:convert';
import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/driver/driver_daily_provider.dart';
import 'package:angkutin/provider/driver/driver_ongoing_service.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:angkutin/screen/complain/complain_screen.dart';
import 'package:angkutin/screen/driver/driver_monitor_screen.dart';
import 'package:angkutin/screen/driver/driver_report_waste_screen.dart';
import 'package:angkutin/screen/driver/driver_request_waste.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/TitleSectionBlue.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../data/model/RequestModel.dart';
import '../../data/model/UserModel.dart' as UserModel;
import '../../provider/driver/driver_service_provider.dart';
import '../../provider/user/user_daily_provider.dart';
import '../../widget/CustomDrawerItem.dart';
import '../user/user_profile_screen.dart';
import 'driver_history_screen.dart';
import 'service/DriverLocationService.dart';

class DriverHomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/driver-homescreen';

  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  UserModel.User? _user;
  UserModel.User? _updateUser;
  Timer? _locationUpdateTimer;
  StreamSubscription<List<RequestService>>? requestSubscription;
  StreamSubscription<GeoPoint>? locationSubscription;

  double latitude = 0;
  double longitude = 0;

  GeoPoint? userLocationLatLng;
  bool hasReports = false;

  @override
  void initState() {
    super.initState();

    _loadData();
    _listenToRequestsStream();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }

  _loadData() async {
    final _isLogin =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .getLoginState();

    final prefs =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .readUserDataLocally();
    if (prefs != null) {
      setState(() {
        _user = UserModel.User.fromJson(jsonDecode(prefs));
      });

      if (_isLogin) {
        Provider.of<UserDailyProvider>(context, listen: false)
            .getUserStream(_user!.email!);

        Provider.of<DriverOngoingService>(context, listen: false)
            .getOngoingRequest(_user!.email!);

        // Listen to reports item
        _listenToReportStream(_user!.email!);
      }
    }
  }

  void _listenToReportStream(String email) {
    Provider.of<DriverServiceProvider>(context, listen: false)
        .getReportFromUser(email);

    final reportStream =
        Provider.of<DriverServiceProvider>(context, listen: false).reportStream;
    reportStream.listen((reports) {
      if (reports.isNotEmpty) {
        setState(() {
          hasReports = true;
        });
      }
    });
  }

  void _listenToRequestsStream() {
    final ongoingService =
        Provider.of<DriverOngoingService>(context, listen: false);
    requestSubscription = ongoingService.requestsStream.listen((requests) {
      if (requests.isNotEmpty) {
        for (var req in requests) {
          _loadAndUpdateDriverLocation(req.type, req.requestId);
        }
      }
    });
  }

  _loadAndUpdateDriverLocation(int type, String requestId) async {
    LocationService locationService = LocationService();

    locationSubscription =
        locationService.locationStream.listen((userLocation) {
      if (mounted) {
        setState(() {
          latitude = userLocation.latitude;
          longitude = userLocation.longitude;

          userLocationLatLng = GeoPoint(latitude, longitude);

          // update driver location based on type and reqId
          _updateDriverLocation(type, requestId, userLocationLatLng!);
        });
      }
    });
  }

  _updateDriverLocation(int type, String reqId, GeoPoint driverLoc) async {
    final driverServiceProv =
        Provider.of<DriverServiceProvider>(context, listen: false);
    await driverServiceProv.updateDriverLocation(type, reqId, driverLoc);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final dailyProvider = Provider.of<DriverDailyProvider>(context);

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: ListTile(
                  title: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: mainApkGradientList,
                      ).createShader(bounds);
                    },
                    child: Text(
                      _user?.fullName ?? "none",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                  subtitle: Text(_user?.email ?? "none@mail.com"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => Navigator.pushNamed(
                      context, UserProfileScreen.ROUTE_NAME),
                ),
              ),
            ),
            CustomDrawerItem(
              title: "Beranda",
              onTap: () => Navigator.pop(context),
            ),
            CustomDrawerItem(
                title: "Permintaan Angkut",
                onTap: () => Navigator.pushNamed(
                    context, DriverRequestWasteScreen.ROUTE_NAME,
                    arguments: _updateUser)),

            StreamBuilder<List<RequestService>>(
              stream: Provider.of<DriverServiceProvider>(context, listen: false)
                  .reportStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  hasReports = true;
                }
                return CustomDrawerItem(
                    title: "Laporan Timbunan Sampah",
                    trailing: hasReports
                        ? Badge(
                            backgroundColor: Colors.red[900],
                          )
                        : null,
                    onTap: () {
                      Navigator.pushNamed(
                          context, DriverReportWasteScreen.ROUTE_NAME,
                          arguments: _updateUser);
                    });
              },
            ),

            CustomDrawerItem(
                title: "Riwayat",
                onTap: () {
                  Navigator.pushNamed(context, DriverHistoryScreen.ROUTE_NAME,
                      arguments: _updateUser?.email);
                }),

            // spacer
            const Spacer(),

            TextButton(
                onPressed: () async {
                  // Batalkan semua stream sebelum logout
                  _locationUpdateTimer?.cancel();
                  requestSubscription?.cancel();
                  locationSubscription?.cancel();

                  // Logout dari Firebase
                  await authProvider.deleteUserDataLocally();
                  await authProvider.saveLoginState(false);
                  await authProvider.deleteRoleLocally();
                  await GoogleSignIn().signOut(); // untuk menghapus sesi login

                  // Navigasi ke layar login setelah beberapa saat
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  });
                },
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red[900]),
                )),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Hai, ${_user?.fullName}!",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: Builder(builder: (context) {
          return Stack(children: [
            IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu_rounded)),
            hasReports == true
                ? Positioned(
                    right: 15,
                    top: 10,
                    child: Badge(
                      backgroundColor: Colors.red[900],
                    ))
                : Container()
          ]);
        }),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(
                  context, ComplainScreen.ROUTE_NAME,
                  arguments: _updateUser),
              icon: const Icon(
                Icons.report_outlined,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<List<RequestService>>(
                  stream:
                      Provider.of<DriverOngoingService>(context, listen: false)
                          .requestsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        width: mediaQueryWidth(context),
                        padding: const EdgeInsets.all(16),
                        child: CachedNetworkImage(
                          imageUrl: dotenv.env['SAMPAH_DAUR_ILUSTRASI_IMAGE']!,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                    } else {
                      final requests = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          return driverServiceCard(req: req);
                        },
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                StreamBuilder(
                  stream: Provider.of<UserDailyProvider>(context, listen: false)
                      .dataStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;

                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _updateUser = data;
                          });
                        }
                      });

                      bool isDailyActive = data.isDaily ?? false;

                      return Column(
                        children: [
                          TitleSection(
                              title: isDailyActive
                                  ? "Angkutan Harian Aktif"
                                  : "Aktifkan status angkutan harian ?"),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: mediaQueryWidth(context),
                            child: CustomButton(
                              title: isDailyActive ? "Stop Layanan" : "Mulai",
                              color: isDailyActive ? redSoftColor : null,
                              onPressed: () async {
                                if (_user != null) {
                                  if (isDailyActive != true) {
                                    // print('Updating isDaily to true');
                                    await dailyProvider.updateDriverDaily(
                                        _user!.email!, true);
                                    await dailyProvider.updateMassDailyUsers(
                                        _user!.address!, true);
                                  } else {
                                    // print('Updating isDaily to false');
                                    await dailyProvider.updateDriverDaily(
                                        _user!.email!, false);
                                    await dailyProvider.updateMassDailyUsers(
                                        _user!.address!, false);
                                  }
                                } else {
                                  print("Error: No user found!");
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class driverServiceCard extends StatelessWidget {
  const driverServiceCard({
    super.key,
    required this.req,
  });

  final RequestService req;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, DriverMonitorScreen.ROUTE_NAME,
            arguments: [req.type, req.requestId, req.userLoc]);
      },
      child: Card(
        child: Container(
          width: mediaQueryWidth(context),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: req.type == 1 ? cGreenSoft : cYellowSoft,
          ),
          child: Column(
            children: [
              Text(
                req.type == 1
                    ? 'Permintaan Sedang Berlangsung'
                    : 'Laporan Masyarakat',
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: cGreenStrong),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Waktu Pengajuan :", style: text14Black54),
                  const Spacer(),
                  Text(
                    formatDate(req.date.toDate().toString()),
                    style: text14Black54,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(formatTime(req.date.toDate().toString()),
                      style: text14Black54),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Diajukan Oleh :", style: text14Black54),
                  const Spacer(),
                  Text(
                    "An. ${req.name}",
                    style: text14Black54,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Wilayah :", style: text14Black54),
                  const Spacer(),
                  Text(
                    req.wilayah,
                    style: text14Black54,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
