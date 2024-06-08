import 'dart:convert';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/provider/driver/driver_daily_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/TitleSectionBlue.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../data/model/UserModel.dart' as UserModel;
import '../../provider/user/user_daily_provider.dart';
import '../../widget/CustomDrawerItem.dart';
import '../user/user_profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/driver-homescreen';

  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  UserModel.User? _user;
  bool? _isDailyActive;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  _loadData() async {
    final prefs =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .readUserDataLocally();
    if (prefs != null) {
      setState(() {
        _user = UserModel.User.fromJson(jsonDecode(prefs));
      });

      Provider.of<UserDailyProvider>(context, listen: false)
          .getUserStream(_user!.email!);
    }

    print("Nilai dariisDaily di init : $_isDailyActive");
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    final dailyProvider = Provider.of<DriverDailyProvider>(context);

    // Handle potential null user
    // final User? user = authProvider.currentUser;

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
            CustomDrawerItem(title: "Angkut Sampah", onTap: () {}),
            CustomDrawerItem(title: "Permintaan Angkut", onTap: () {}),
            CustomDrawerItem(title: "Laporan Timbunan Sampah", onTap: () {}),

            // spacer
            const Spacer(),

            TextButton(
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 500), () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );

                    await FirebaseAuth.instance.signOut();
                    await authProvider.deleteUserDataLocally();
                    await authProvider.saveLoginState(false);
                    await GoogleSignIn().signOut(); // untuk meghapus sesi login
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
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu_rounded));
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
          child: Column(
            children: [
              Container(
                width: mediaQueryWidth(context),
                padding: const EdgeInsets.all(16),
                // decoration: containerBorderWithRadius,
                child: CachedNetworkImage(
                  imageUrl: dotenv.env['SAMPAH_DAUR_ILUSTRASI_IMAGE']!,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              TitleSection(title: "Kamu siap bertugas ?"),
              Text("Anda memiliki jadwal pengangkutan hari ini"),
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
                    if (data.isDaily == true) {
                      return SizedBox(
                        width: mediaQueryWidth(context),
                        child: CustomButton(
                          title: "Stop Layanan",
                          color: redSoftColor,
                          onPressed: () async {
                            if (_user != null) {
                              print('Updating isDaily to false');
                              await dailyProvider.updateDriverDaily(
                                  _user!.email!, false);
                              await dailyProvider.updateMassDailyUsers(
                                  "Kecamatan Medan Denai", false);
                            } else {
                              print("Error: No user found!");
                            }
                          },
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: mediaQueryWidth(context),
                        child: CustomButton(
                          title: "Mulai",
                          onPressed: () async {
                            if (_user != null) {
                              print('Updating isDaily to true');
                              await dailyProvider.updateDriverDaily(
                                  _user!.email!, true);
                              await dailyProvider.updateMassDailyUsers(
                                  "Kecamatan Medan Denai", true);
                            } else {
                              print("Error: No user found!");
                            }
                          },
                        ),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),

              // dailyProvider.isUpdateLoading == true
              //     ? const Center(
              //         child: CircularProgressIndicator(),
              //       )
              //     : SizedBox(
              //         width: mediaQueryWidth(context),
              //         child: CustomButton(
              //           title: dailyProvider.isDailyActive == true
              //               ? "Stop"
              //               : "Mulai",
              //           onPressed: () async {
              //             // Directly use dailyProvider.isDailyActive for update data
              //             if (_user != null) {
              //               dailyProvider.updateDriverDaily(_user!.email!,
              //                   {"isDaily": !dailyProvider.isDailyActive!});
              //             } else {
              //               print("Error no user found!");
              //             }
              //           },
              //         ),
              //       ),
            ],
          ),
        ),
      ),
    );
  }
}
