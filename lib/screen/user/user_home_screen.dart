import 'package:angkutin/data/model/RequestModel.dart';
import 'package:angkutin/provider/user/user_request_provider.dart';
import 'package:angkutin/screen/user/user_monitor_request_screen.dart';
import 'package:angkutin/widget/SmallTextGrey.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:angkutin/screen/user/user_history_screen.dart';
import 'package:angkutin/screen/user/user_profile_screen.dart';
import 'package:angkutin/widget/DailyCarbageCard.dart';

import '../../common/utils.dart';
import '../../widget/CarbageHaulCard.dart';
import '../../widget/CustomDrawerItem.dart';
import '../../widget/ServiceCard.dart';
import '../../data/model/UserModel.dart' as UserModel;
import 'request_service_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-homescreen';

  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // late dynamic  _requestsFuture;
  final String userId = 'userId1';

  @override
  void initState() {
    super.initState();

    // get data request
    // Provider.of<UserRequestProvider>(context).getOngoingRequest(userId);

    Future.microtask(() =>
        Provider.of<UserRequestProvider>(context, listen: false)
            .getOngoingRequest(userId));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    // final reqProvider = Provider.of<UserRequestProvider>(context);
    // Handle potential null user
    final UserModel.User? user = authProvider.currentUser;
    // final List<RequestService> userStream = reqProvider.requests;

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              // decoration: const BoxDecoration(
              //   color: mainColor,
              // ),
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
                      user?.name ?? "none",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                  subtitle: Text(user?.email ?? "none@mail.com"),
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
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await authProvider.deleteUserDataLocally();
                  await authProvider.saveLoginState(false);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ); // authProvider
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
          "Hai, Nama",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu_rounded));
        }),
        // Expanded(child: Image.asset("assets/angkutin_logo_fill_mini.png"),),

        actions: [
          IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(
                  Icons.notifications,
                  color: secondaryColor,
                ),
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
                DailyCarbageCard(
                  status: "Petugas akan datang",
                  description: "Siapkan sampah yang akan diangkut",
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
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(8),
                        width: mediaQueryWidth(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cGreenSofter,
                        ),
                        child: Text(
                          "Kamu belum mengajukan permintaan pengangkutan sampah",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.green[700]),
                        ),
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
                            status: request.isDelivered,
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
                        context, RequestServiceScreen.ROUTE_NAME,
                        arguments: "Permintaan Angkut Sampah");
                  },
                ),
                ServiceCard(
                  title: "Lapor Sampah Liar",
                  subtitle: "Lapor dengan cepat dan mudah!",
                  imageUrl: dotenv.env['TUMPUKAN_SAMPAH_ILUSTRASI_IMAGE']!,
                  onPressed: () {
                    Navigator.pushNamed(
                        context, RequestServiceScreen.ROUTE_NAME,
                        arguments: "Lapor Sampah Liar");
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
