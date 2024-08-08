import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';

import '../../common/state_enum.dart';
import '../../database/firestore_database.dart';

class MonitorProvider with ChangeNotifier {
  ResultState? _state;
  String? _errorMessage;
  final StreamController<RequestService> _serviceDataController =
      StreamController.broadcast();

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;

  Stream<RequestService> get dataStream => _serviceDataController.stream;

  @override
  void dispose() {
    _serviceDataController.close();
    super.dispose();
  }

  Future<void> getRequestDataStream(int type, String requestId) async {
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      String collectionPath;
      if (type == 1) {
        collectionPath = "carbage";
      } else if (type == 2) {
        collectionPath = "report";
      } else {
        throw Exception("Invalid type");
      }

      final docRef = db
          .collection("requests")
          .doc(collectionPath)
          .collection("items")
          .doc(requestId);

      docRef.snapshots().listen((event) {
        _serviceDataController.add(RequestService.fromFirestore(event, null));
        _state = ResultState.success;
        notifyListeners();
      }, onError: (error) {
        _state = ResultState.error;
        _errorMessage = error.toString();
        notifyListeners();
      });
    } catch (e) {
      _state = ResultState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
