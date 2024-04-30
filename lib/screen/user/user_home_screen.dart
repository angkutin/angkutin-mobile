import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:angkutin/screen/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    // Handle potential null user
    // final User? user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading:
            Expanded(child: Image.asset("assets/angkutin_logo_fill_mini.png")),
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
              SizedBox(
                width: mediaQueryWidth(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selamat Datang,",
                      style: TextStyle(height: 2),
                    ),
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          // begin: Alignment.topCenter,
                          // end: Alignment.bottomCenter,
                          colors: mainApkGradient,
                        ).createShader(bounds);
                      },
                      child: Text(
                        authProvider.currentUser?.name ?? "none",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? "none@mail.com",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  ],
                ),
              ),

              // Card(
              //   child: Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12),
              //       color: Colors.green,
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         SizedBox(
              //           width: 36, // Adjust width as needed
              //           height: 36, // Adjust height as needed
              //           child: Image.asset(
              //             'assets/angkutin_logo_green.png',
              //             fit:
              //                 BoxFit.contain, // Adjust fit for desired behavior
              //           ),
              //         ),
              //         const Divider(
              //           height: 24,
              //           color: Colors.transparent,
              //         ),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 const Text('Selamat Datang'),
              //                 const Text(
              //                   'Lorem Ipsum',
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.w500, fontSize: 18),
              //                 ),
              //                 TextButton(
              //                   onPressed: () {},
              //                   style: TextButton.styleFrom(
              //                     padding: const EdgeInsets.symmetric(
              //                         vertical: 4, horizontal: 0),
              //                   ),
              //                   child: const Text('lihat detail profil'),
              //                 ),
              //               ],
              //             ),
              //             const CircleAvatar(
              //               radius: 36,
              //               backgroundImage:
              //                   AssetImage('assets/angkutin_logo_green.png'),
              //             ),
              //           ],
              //         )
              //       ],
              //     ),
              //   ),
              // ),

              // Text(user?.displayName ?? ''),
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await authProvider.deleteUserDataLocally();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ); // authProvider
                  },
                  child: Text("Logout"))
            ],
          ),
        ),
      ),
    );
  }
}
