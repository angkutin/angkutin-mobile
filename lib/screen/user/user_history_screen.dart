import 'package:angkutin/common/constant.dart';
import 'package:flutter/material.dart';

class UserHistoryScreen extends StatelessWidget {
    static const ROUTE_NAME = '/user-history-screen';

  const UserHistoryScreen({super.key});

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
              ]),
        ),
        body: const Column(
          children: [
            Flexible(
              child: TabBarView(
                children: [UserHaulHistory(), UserReportHistory()],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserHaulHistory extends StatelessWidget {
  const UserHaulHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return _historyItemCard();
      },
    );
  }
}

class _historyItemCard extends StatelessWidget {
  const _historyItemCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: containerBorderWithRadius,
        child: ListTile(
          title: Text("data"),
          subtitle: Text("Selasa, 8 Mei 2024 | 16.00 WIB"),
          trailing: Text("Selesai"),
        ),
      ),
    );
  }
}

class UserReportHistory extends StatelessWidget {
  const UserReportHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return _historyItemCard();
      },
    );
  }
}
