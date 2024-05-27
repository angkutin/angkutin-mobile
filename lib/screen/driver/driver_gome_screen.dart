import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../widget/CarbageHaulCard.dart';

class DriverHomeScreen extends StatelessWidget {
  static const ROUTE_NAME = '/driver-homescreen';

  const DriverHomeScreen({super.key});

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
                      authProvider.currentUser?.name ?? "none",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                  subtitle: Text("email@gmail.com"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => print("Profile on tap"),
                ),
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
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
              Card(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // color: Colors.green,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Angkut Harian',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black54),
                              ),
                              const Text(
                                'Belum ada',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                              const Text(
                                'Petugas sedang anu',
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              CarbageHaulCard(
                onPressed: () => print("pantau clicked"),
                status: "Diterima",
              ),
              Card(
                child: Container(
                    width: mediaQueryWidth(context),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: Colors.green,
                    ),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: dotenv.env['INTRODUCTION_2_IMAGES']!,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      title: Text("Minta Angkut"),
                      subtitle: Text("minta angkut blablabla"),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
