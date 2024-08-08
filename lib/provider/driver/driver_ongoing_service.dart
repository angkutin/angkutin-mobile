import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/state_enum.dart';

class DriverOngoingService with ChangeNotifier {
  // get request
  ResultState? _reqState;
  String? _reqErrorMessage;
  bool? _reqIsLoading = false;
  final StreamController<List<RequestService>> _requestsController =
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

  Future<void> getOngoingRequest(String idPetugas) async {
    _reqState = ResultState.loading;
    _reqErrorMessage = null;
    _reqIsLoading = true;
    notifyListeners();

    try {
      final carbageStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .where('idPetugas', isEqualTo: idPetugas)
          .where('isDone', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RequestService.fromFirestore(doc, null))
              .toList());

      final reportStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('report')
          .collection('items')
          .where('idPetugas', isEqualTo: idPetugas)
          .where('isAcceptByDriver', isEqualTo: true)
          .where('isDone', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RequestService.fromFirestore(doc, null))
              .toList());

      final dataStream = Rx.combineLatest2<List<RequestService>,
          List<RequestService>, List<RequestService>>(
        carbageStream,
        reportStream,
        (carbageData, reportData) => [...carbageData, ...reportData],
      );
      
      dataStream.listen((data) {
        _requestsController.add(data); // Add data to the stream
      });
      _reqState = ResultState.success;
    } catch (error) {
      _reqState = ResultState.error;
      _reqErrorMessage = error.toString();
    } finally {
      _reqIsLoading = false;
      notifyListeners();
    }
  }
}
