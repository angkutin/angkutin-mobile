import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:angkutin/widget/TitleSectionBlue.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../widget/CarbageHaulCard.dart';
import '../../data/model/UserModel.dart' as UserModel;
import '../../widget/CustomDrawerItem.dart';
import '../user/user_history_screen.dart';
import '../user/user_profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/driver-homescreen';

  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  UserModel.User? _user;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

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
          "INI DRIVER",
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
              SizedBox(
                  width: mediaQueryWidth(context),
                  child: CustomButton(title: "Mulai", onPressed: () {})),
            ],
          ),
        ),
      ),
    );
  }
}
