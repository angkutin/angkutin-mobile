// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/common/constant.dart';
import 'package:flutter/material.dart';

class RequestServiceScreen extends StatefulWidget {
  static const ROUTE_NAME = '/user-requestservice_screen';

  final String titleScreen;
  const RequestServiceScreen({
    Key? key,
    required this.titleScreen,
  }) : super(key: key);

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.titleScreen,
              style: basicTextStyleBlack,
            ),
          ],
        ),
      ),
    );
  }
}
