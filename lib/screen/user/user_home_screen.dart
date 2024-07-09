// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/user/user_daily_provider.dart';
import 'package:angkutin/provider/user/user_request_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:angkutin/screen/user/user_history_screen.dart';
import 'package:angkutin/screen/user/user_monitor_request_screen.dart';
import 'package:angkutin/screen/user/user_profile_screen.dart';
import 'package:angkutin/widget/DailyCarbageCard.dart';

import '../../common/utils.dart';
import '../../data/model/UserModel.dart' as UserModel;
import '../../widget/CarbageHaulCard.dart';
import '../../widget/CustomDrawerItem.dart';
import '../../widget/ServiceCard.dart';
import '../complain/complain_screen.dart';
import 'request_service_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-homescreen';

  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String? _userEmail;
  String? _userWilayah;
  UserModel.User? _user;

  @override
  void initState() {
    super.initState();

    _loadData();
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
        _userEmail = _user?.email;
        _userWilayah = extractLastPart(_user!.address!);
        print("user wilayah $_userWilayah");
      });
    }
    print("update user ${_user?.email} ${_user?.address}");

    if (_isLogin) {
      Provider.of<UserRequestProvider>(context, listen: false)
          .getOngoingRequest(_userEmail!);

      Provider.of<UserDailyProvider>(context, listen: false)
          .getDailyDriverAvailable(_userWilayah!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

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
              title: "Riwayat",
              onTap: () => Navigator.pushNamed(
                  context, UserHistoryScreen.ROUTE_NAME,
                  arguments: _user?.email),
            ),

            // spacer
            const Spacer(),

            TextButton(
                onPressed: () async {
                  

                  Provider.of<UserRequestProvider>(context, listen: false)
                      .cancelSubscription();

                  // Logout dari Firebase
                  // await FirebaseAuth.instance.signOut();
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
        shadowColor: Colors.black,
        title: Text(
          "Hai, ${_user?.fullName}!",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu_rounded));
        }),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(
                  context, ComplainScreen.ROUTE_NAME,
                  arguments: _user),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("Di user sudah buat pilih tipe dan pembayaran, di driver belom atur untuk permintaan request ni",style: text18cgs18,),
                // Text("Lokasi permintaan masih gaje, di driver lokasi user di Alpha, di user lokasinya di Gbunga", style: text18cgs18,),
                StreamBuilder(
                  stream: Provider.of<UserDailyProvider>(context, listen: false)
                      .driverDataStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      if (data.isEmpty) {
                        return const EmptyServiceCard(
                          contentText: "Belum ada jadwal pengangkutan",
                        );
                      } else if (data.length < 3) {
                        // waktu pengangkutan lama
                        return DailyCarbageCard(
                          status: "Siapkan sampahmu.",
                          indicatorColor: Colors.orange[800]!,
                          description:
                              "Petugas lebih sedikit, mungkin membutuhkan waktu.",
                        );
                      } else if (data.length >= 3 && data.length <= 5) {
                        // waktu normal
                        return const DailyCarbageCard(
                          status: "Siapkan sampahmu.",
                          indicatorColor: Colors.blue,
                          description: "Waktu pengangkutan normal.",
                        );
                      } else {
                        // waktu cepat
                        return DailyCarbageCard(
                          status: "Siapkan sampahmu.",
                          indicatorColor: Colors.green[800]!,
                          description:
                              "Pengangkutan lebih cepat dari biasanya.",
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                ),

                // stream
                StreamBuilder<List<RequestService>>(
                  stream:
                      Provider.of<UserRequestProvider>(context, listen: false)
                          .requestsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const EmptyServiceCard(
                        contentText:
                            "Kamu belum mengajukan permintaan pengangkutan sampah",
                        color: cGreenSoft,
                      );
                    } else {
                      final requests = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          if (request.type == 1) {
                            return CarbageHaulCard(
                              onPressed: () => Navigator.pushNamed(
                                  context, UserMonitorRequestScreen.ROUTE_NAME,
                                  arguments: [request.type, request.requestId]),
                              req: request,
                            );
                          } else {
                            // ini report
                            return reportCard(context, request, () async {
                              final userServiceProv =
                                  Provider.of<UserRequestProvider>(context,
                                      listen: false);
                              await userServiceProv.deleteRequest(request);
                            });
                          }
                        },
                      );
                    }
                  },
                ),

                const SizedBox(
                  height: 30,
                ),

                const Text(
                  "Layanan",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: blackColor),
                ),
                ServiceCard(
                  title: "Minta Angkut",
                  subtitle: "Butuh petugas angkut sampahmu? Klik disini!",
                  imageUrl: dotenv.env['ANGKUT_SAMPAH_ILUSTRASI_IMAGE']!,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RequestServiceScreen.ROUTE_NAME,
                      arguments: [1, _user],
                    );
                  },
                ),
                ServiceCard(
                  title: "Lapor Sampah Liar",
                  subtitle: "Lapor dengan cepat dan mudah!",
                  imageUrl: dotenv.env['TUMPUKAN_SAMPAH_ILUSTRASI_IMAGE']!,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RequestServiceScreen.ROUTE_NAME,
                      arguments: [2, _user],
                    );
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

class EmptyServiceCard extends StatelessWidget {
  final String contentText;
  final Color? color;
  const EmptyServiceCard({
    Key? key,
    required this.contentText,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(8),
      width: mediaQueryWidth(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color ?? softBlueColor,
      ),
      child: Text(
        contentText,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.w500, fontSize: 16, color: blackColor),
      ),
    );
  }
}

Widget reportCard(context, RequestService req, VoidCallback onPressed) {
  return Card(
    child: Container(
      width: mediaQueryWidth(context),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cYellowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Sampah Liar',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 16, color: cGreenStrong),
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
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Status",
            style: text14Black54,
          ),
          _statusReport(req, onPressed),
        ],
      ),
    ),
  );
}

Widget _statusReport(RequestService req, VoidCallback onPressed) {
  if (req.isDelivered == true) {
    if (req.isAcceptByDriver == true) {
      return const Text("Laporan Valid\nPetugas akan datang.",
          style: text18cgs18);
    } else {
      return const Text("Laporan Valid\nMenunggu petugas", style: text18cgs18);
    }
  } else {
    return Column(children: [
      const Text("Menunggu Tinjauan", style: text18cgs18),
      Row(children: [
        const Spacer(),
        GestureDetector(
            onTap: onPressed,
            child: const FaIcon(
              FontAwesomeIcons.trashCan,
              size: 12,
            )),
      ])
    ]);
  }
}
