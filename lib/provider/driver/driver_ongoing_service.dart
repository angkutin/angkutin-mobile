import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/state_enum.dart';

class DriverOngoingService with ChangeNotifier {
  // get request
  ResultState? _reqState;
  String? _reqErrorMessage;
  bool? _reqIsLoading = false;
  StreamController<List<RequestService>> _requestsController =
      StreamController.broadcast();

  ResultState? get reqState => _reqState;
  String? get reqErrorMessage => _reqErrorMessage;
  bool? get reqIsLoading => _reqIsLoading;

  Stream<List<RequestService>> get requestsStream => _requestsController.stream;

  @override
  void dispose() {
    _requestsController.close();
    super.dispose();
  }

  Future<void> getOngoingRequest(String petugas) async {
    _reqState = ResultState.loading;
    _reqErrorMessage = null;
    _reqIsLoading = true;
    notifyListeners();

    try {
      final dataStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .where('namaPetugas', isEqualTo: petugas)
          .where('isDone', isEqualTo: false)
          .snapshots();

      dataStream.listen((querySnapshot) {
        List<RequestService> requests = querySnapshot.docs
            .map((doc) => RequestService.fromFirestore(doc, null))
            .toList();
        _requestsController.add(requests);
      });

      _reqState = ResultState.success;
    } catch (error) {
      _reqState = ResultState.error;
      _reqErrorMessage = error.toString();
      print("Errornya $_reqErrorMessage");
    } finally {
      _reqIsLoading = false;
      notifyListeners();
    }
  }
}
