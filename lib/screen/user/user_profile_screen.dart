// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constant.dart';
import '../../data/model/UserModel.dart' as UserModel;
import '../../provider/auth/auth_provider.dart';
import '../../widget/CustomListTile.dart';

class UserProfileScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-profile-screen';

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserModel.User? _user;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _user?.imageUrl != null
            ? const Text(
              "Foto Rumah",
              style: basicTextStyleBlack,
            ) : Container(),
            _user?.imageUrl != null
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: containerBorderWithRadius.copyWith(
                        border: Border.all(color: softBlueColor)),
                    child: CachedNetworkImage(
                      imageUrl: _user!.imageUrl!,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  )
                : Container(),
            CustomListTile(
              title: "Nama",
              value: _user?.name ?? "None",
            ),
            CustomListTile(
              title: "Wilayah",
              value: _user?.address ?? "None",
            ),
            CustomListTile(
              title: "Nomor Hp Aktif",
              value: _user?.activePhoneNumber.toString() ?? "none",
            ),
            CustomListTile(
              title: "Nomor Hp Cadangan",
              value: _user?.optionalPhoneNumber != null
                  ? _user!.optionalPhoneNumber.toString()
                  : "tidak diatur",
            ),
                      const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
