// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../common/utils.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onPressed;
  Widget? trailing;
   ServiceCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onPressed,
    this.trailing
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        child: Container(
            width: mediaQueryWidth(context),
            padding: const EdgeInsets.all(16),
            decoration: containerBorderWithRadius,
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: blackColor),
              ),
              subtitle: Text(
                subtitle,
                style: const TextStyle(
                    // fontWeight: FontWeight.w500,
                    color: softBlackColor),
              ),
              trailing: trailing,
            )
            ),
            
      ),
    );
  }
}
