// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constant.dart';
import '../../common/utils.dart';
import '../../provider/user/user_daily_provider.dart';

class DriverHistoryScreen extends StatelessWidget {
  final String driverId;
  static const ROUTE_NAME = '/driver-history-screen';

  const DriverHistoryScreen({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat"),
          bottom: const TabBar(
            padding: EdgeInsets.all(16),
            indicator: BoxDecoration(color: mainColor),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.symmetric(vertical: 8),
            labelColor: Colors.white,
            tabs: [
              Text("Minta Angkut"),
              Text("Sampah Liar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserHaulHistory(
              driverId: driverId,
            ),
            UserReportHistory(
              driverId: driverId,
            )
          ],
        ),
      ),
    );
  }
}

class UserReportHistory extends StatefulWidget {
  final String driverId;
  const UserReportHistory({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<UserReportHistory> createState() => _UserReportHistoryState();
}

class _UserReportHistoryState extends State<UserReportHistory> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserDailyProvider>(context, listen: false)
            .getUserStream(widget.driverId));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserDailyProvider>(context).dataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data?.services ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("Tidak ada data"));
          } else {
            final filteredServices =
                data.where((service) => service['type'] == 2).toList();
            if (filteredServices.isEmpty) {
              return const Center(child: Text("Tidak ada data"));
            } else {
              final reversedServices = filteredServices.reversed.toList();

              return ListView.builder(
                itemCount: reversedServices.length,
                itemBuilder: (context, index) {
                  final service = reversedServices[index];
                  return _historyItemCard(service, context);
                },
              );
            }
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class UserHaulHistory extends StatefulWidget {
  final String driverId;
  const UserHaulHistory({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<UserHaulHistory> createState() => _UserHaulHistoryState();
}

class _UserHaulHistoryState extends State<UserHaulHistory> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserDailyProvider>(context, listen: false)
            .getUserStream(widget.driverId));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserDailyProvider>(context).dataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data?.services ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("Tidak ada data"));
          } else {
            final filteredServices =
                data.where((service) => service['type'] == 1).toList();
            if (filteredServices.isEmpty) {
              return const Center(child: Text("Tidak ada data"));
            } else {
              final reversedServices = filteredServices.reversed.toList();
              return ListView.builder(
                itemCount: reversedServices.length,
                itemBuilder: (context, index) {
                  final service = reversedServices[index];
                  return _historyItemCard(service, context);
                },
              );
            }
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Widget _historyItemCard(service, BuildContext context) {
  final dateTime = timestampToDatetime(service['date'].toString());

  return Card(
    child: Container(
      color: cBlueSoft,
      child: ListTile(
        title: Text(service['name'] ?? 'No Name'),
        subtitle: Text('${service['senderEmail']}\n${service['wilayah']}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Diajukan"),
            Text(formatDate(dateTime.toString()))
          ],
        ),
      ),
    ),
  );
}
