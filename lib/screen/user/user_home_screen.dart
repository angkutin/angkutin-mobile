// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'request_service_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-homescreen';

  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // late dynamic  _requestsFuture;
  String? _userEmail;
  String? _userWilayah;
  UserModel.User? _user;

  @override
  void initState() {
    super.initState();

    // get data request
    // Provider.of<UserRequestProvider>(context).getOngoingRequest(userId);
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
        _userWilayah = extractLastPart(_user!.address!) ;
        print("user wilayah $_userWilayah");
      });
    }

    if (_isLogin) {
      Provider.of<UserRequestProvider>(context, listen: false)
          .getOngoingRequest(_userEmail!);
      // Provider.of<UserDailyProvider>(context, listen: false)
      //     .getUserStream(_userEmail!);
      Provider.of<UserDailyProvider>(context, listen: false)
          .getDailyDriverAvailable(_userWilayah!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    // final UserModel.User? user = authProvider.currentUser;

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
                        // begin: Alignment.topCenter,
                        // end: Alignment.bottomCenter,
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
              onTap: () =>
                  Navigator.pushNamed(context, UserHistoryScreen.ROUTE_NAME),
            ),

            // spacer
            const Spacer(),

            TextButton(
                onPressed: () {
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );

                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn().signOut(); // untuk meghapus sesi login

                    await authProvider.deleteUserDataLocally();
                    await authProvider.deleteRoleLocally();
                    await authProvider.saveLoginState(false);
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        return  DailyCarbageCard(
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
                        return  DailyCarbageCard(
                          status: "Siapkan sampahmu.",
                          indicatorColor: Colors.green[800]!,
                          description:
                              "Pengangkutan lebih cepat dari biasanya.",
                        );
                      }
                    } else {
                      return Container(
                        child: Text("Halo cuki"),
                      );
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
                      return EmptyServiceCard(
                        contentText:
                            "Kamu belum mengajukan permintaan pengangkutan sampah",
                        color: Colors.green[700],
                      );
                    } else {
                      final requests = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return CarbageHaulCard(
                            onPressed: () => Navigator.pushNamed(
                                context, UserMonitorRequestScreen.ROUTE_NAME),
                            req: request,
                          );
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
