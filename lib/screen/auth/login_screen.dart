import 'dart:convert';

import 'package:angkutin/common/constant.dart';
import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/screen/auth/fill_user_data_screen.dart';
import 'package:angkutin/screen/driver/driver_gome_screen.dart';
import 'package:angkutin/screen/user/user_home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../common/utils.dart';
import '../../provider/auth/auth_provider.dart';
import '../../widget/CustomButton.dart';
import '../../widget/TitleSectionBlue.dart';
import '../../data/model/UserModel.dart' as userModel;

class LoginScreen extends StatelessWidget {
  static const ROUTE_NAME = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<AuthenticationProvider>(context);
    String? imageUrl = dotenv.env['LOGIN_URL_IMAGES'];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 36,
              ),
              const TitleSection(
                title: 'Masuk',
              ),
              const Text(
                "Saatnya untuk memulai perjalanan Anda dalam memberdayakan lingkungan. Sebelum itu, daftar dulu yuk",
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 54,
              ),
              SizedBox(
                width: mediaQueryWidth(context),
                height: mediaQueryHeight(context) / 2.5,
                // color: Colors.amber,
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const Spacer(),
              signInProvider.isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      width: mediaQueryWidth(context),
                      child: CustomButton(
                        title: 'Masuk dengan Google',
                        onPressed: () async {
                          try {
                            await signInProvider.signInWithGoogleProv();

                            if (signInProvider.state == ResultState.success) {
                              // ngecek apakah user sudah ngisi data melalui local storage
                              final String? user =
                                  await signInProvider.readUserDataLocally();

                              userModel.User userData =
                                  userModel.User.fromJson(jsonDecode(user!));

                              if (userData.role == "Masyarakat" ||
                                  userData.role == "masyarakat") {
                                signInProvider.saveRoleState("Masyarakat");
                              } else if (userData.role == "Petugas" ||
                                  userData.role == "petugas") {
                                signInProvider.saveRoleState("Petugas");
                              } else {
                                // print("LOGIN SCREEN : ada masalah dalam membaca role");
                              }

                              bool isFillData = userData.latitude != null;
                              String role = userData.role!;

                              // checking status fill data user
                              if (isFillData) {
                                signInProvider.saveLoginState(true);
                                // Navigate to screen based on user role
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  if (role == "Masyarakat" ||
                                      role == "masyarakat") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserHomeScreen(),
                                      ),
                                    );
                                  } else if (role == "Petugas" ||
                                      role == "petugas") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DriverHomeScreen(),
                                      ),
                                    );
                                  }
                                });
                              } else {
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FillUserDataScreen(),
                                    ),
                                  );
                                });
                              }
                            } else {
                              // Handle non-success states (loading, error)
                              if (signInProvider.state == ResultState.loading) {
                                showInfoSnackbar(context, "Memproses masuk...");
                              } else if (signInProvider.state ==
                                  ResultState.error) {
                                showInfoSnackbar(
                                    context, "Terjadi kesalahan ketika masuk");
                              }
                            }
                          } on Exception catch (error) {
                            showInfoSnackbar(context,
                                "Terjadi kesalahan ketika masuk: Exception");
                            print(error.toString()); // Log error for debugging
                          }
                        },
                      ),
                    ),
              const SizedBox(
                height: 16,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Dengan masuk, kamu menyetujui ',
                  style: const TextStyle(
                    color: Colors.black,
                  ), // Mengubah warna teks

                  children: [
                    TextSpan(
                      text: 'Privasi',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: blueApkColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showInfoSnackbar(context, "Privasi clicked !");
                        },
                    ),
                    const TextSpan(text: ' dan '),
                    TextSpan(
                      text: 'Terms & Condition',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: blueApkColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showInfoSnackbar(context, "Terms and Cond clicked !");
                        },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
