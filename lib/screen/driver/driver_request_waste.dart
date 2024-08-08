// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:angkutin/data/model/UserModel.dart';
import 'package:angkutin/screen/driver/driver_detail_service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:angkutin/provider/driver/driver_service_provider.dart';

import '../../common/constant.dart';
import '../../common/utils.dart';
import '../../data/model/RequestModel.dart';

class DriverRequestWasteScreen extends StatefulWidget {
  final User dataDriver;
  static const ROUTE_NAME = '/driver-requestscreen';

  const DriverRequestWasteScreen({
    Key? key,
    required this.dataDriver,
  }) : super(key: key);

  @override
  State<DriverRequestWasteScreen> createState() =>
      _DriverRequestWasteScreenState();
}

class _DriverRequestWasteScreenState extends State<DriverRequestWasteScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<DriverServiceProvider>(context, listen: false)
          ..getCarbageRequestFromUser(widget.dataDriver.address!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permintaan Pengangkutan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<List<RequestService>>(
          stream: Provider.of<DriverServiceProvider>(context, listen: false)
              .requestsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(8),
                width: mediaQueryWidth(context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cGreenSofter,
                ),
                child: Text(
                  "Belum ada yang mengajukan permintaan pengangkutan sampah",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.green[700]),
                ),
              );
            } else {
              final requests = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(8),
                    width: mediaQueryWidth(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cGreenSoft.withOpacity(.8),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            request.wilayah,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: blackColor),
                          ),
                          subtitle: Text(
                              "${formatDate(request.date.toDate().toString())} ${formatTime(request.date.toDate().toString())}\nAn. ${request.name}"),
                          trailing: TextButton(
                              onPressed: () {
                                final driverLoc = widget.dataDriver;
                                print("Mengirim lokasi ${driverLoc.latitude} ke detail");
                                
                                Navigator.pushNamed(context,
                                  DriverDetailServiceScreen.ROUTE_NAME,
                                  arguments: [
                                    request,
                                    GeoPoint(driverLoc.latitude!,
                                        driverLoc.longitude!)
                                  ]);
                                                              
                              },
                              child: const Text("Lihat Detail")),
                        )
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
