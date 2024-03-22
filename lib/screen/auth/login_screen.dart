import 'package:angkutin/database/realtime_database.dart';
import 'package:angkutin/screen/auth/service/google_sign_in.dart';
import 'package:angkutin/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/constant.dart';
import '../../common/utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Datang !",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              "Saatnya untuk memulai perjalanan Anda dalam memberdayakan lingkungan, satu langkah di satu waktu. Siap untuk memulai?",
              textAlign: TextAlign.start,
            ),
            const SizedBox(
              height: 52,
            ),
            SizedBox(
                width: mediaQueryWidth(context),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsetsDirectional.symmetric(vertical: 14),
                        backgroundColor: cGreenStrong,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      try {
                        final googleUser = await signInWithGoogle();

                      print("Logged in as : ${googleUser.user?.displayName}");

                      // simpan data
                      await saveUserData(googleUser.user?.displayName ?? "",
                          googleUser.user?.email ?? "", "masyarakat");

                      // Navigasi ke HomeScreen
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      });
                      } catch (e) {
                        print("Error login : $e");
                      }
                      
                    },
                    child: const Text(
                      "Masuk dengan Google",
                      style: TextStyle(color: Colors.white),
                    )))
          ],
        ),
      ),
    );
  }
}
