import 'package:flutter/material.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

double mediaQueryWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;
double mediaQueryHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;

// show snackbar
void showInfoSnackbar(BuildContext context, String message) {
  if (message.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}
