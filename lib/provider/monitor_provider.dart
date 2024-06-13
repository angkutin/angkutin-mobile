import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';

import '../../common/state_enum.dart';
import '../../database/firestore_database.dart';

class MonitorProvider with ChangeNotifier {
  ResultState? _state;
  String? _errorMessage;
  StreamController<RequestService> _serviceDataController =
      StreamController.broadcast();

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;

  Stream<RequestService> get dataStream => _serviceDataController.stream;

  @override
  void dispose() {
    _serviceDataController.close();
    super.dispose();
  }

  Future<void> getRequestDataStream(String requestId) async {
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = db
          .collection("requests")
          .doc("carbage")
          .collection("items")
          .doc(requestId);
      docRef.snapshots().listen((event) {
        _serviceDataController.add(RequestService.fromFirestore(event, null));
        _state = ResultState.success;
        print("current data: ${event.data()}");
      }, onError: (error) {
        print("Listen failed: $error");
        _state = ResultState.error;
        _errorMessage = error.toString();
        print("Errornya $_errorMessage");
      });
    } finally {
      notifyListeners();
    }
  }
}
