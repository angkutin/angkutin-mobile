// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../common/constant.dart';
import '../../widget/CustomListTile.dart';

class UserProfileScreen extends StatelessWidget {
  static const ROUTE_NAME = '/user-profile-screen';

  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
      ),
      body: Column(
        children: [
          const Text(
            "Foto Rumah",
            style: basicTextStyleBlack,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: containerBorderWithRadius.copyWith(
                border: Border.all(color: softBlueColor)),
            child: CachedNetworkImage(
              imageUrl: dotenv.env['TUMPUKAN_SAMPAH_ILUSTRASI_IMAGE']!,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          CustomListTile(
            title: "Nama",
            value: "Kunto Aji",
          ),
          CustomListTile(
            title: "Wilayah",
            value: "Johor",
          ),
          CustomListTile(
            title: "Nomor Hp Aktif",
            value: "0812",
          ),
          CustomListTile(
            title: "Nomor Hp Cadangan",
            value: "0812",
          ),
          CustomListTile(
            title: "Koordinat",
            value: "12.121212, -12.12121",
            trailing: IconButton(
                onPressed: () {
                  print("Ganti koordinat");
                },
                icon: const Icon(
                  Icons.edit_location_outlined,
                  color: softBlueColor,
                )),
          ),
        ],
      ),
    );
  }
}

