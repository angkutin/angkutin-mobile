import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/state_enum.dart';
import '../../database/storage_service.dart';

class UserRequestProvider with ChangeNotifier {
  final StorageService storageService;
  UserRequestProvider(this.storageService);

  ResultState? _state;
  String? _errorMessage;
  bool? _isLoading = false;

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;
  bool? get isLoading => _isLoading;

  Future<void> createRequest(
      {String? path, RequestService? requestService}) async {
    _state = ResultState.loading;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final CollectionReference requestsCollection = FirebaseFirestore.instance
          .collection('requests')
          .doc(path)
          .collection('items');

      await requestsCollection
          .doc(requestService?.requestId)
          .set(requestService?.toFirestore());

      _state = ResultState.success;
    } catch (error) {
      _state = ResultState.error;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// get request
  ResultState? _reqState;
  String? _reqErrorMessage;
  bool? _reqIsLoading = false;
  final StreamController<List<RequestService>> _requestsController =
      StreamController.broadcast();
        StreamSubscription? _subscription;


  ResultState? get reqState => _reqState;
  String? get reqErrorMessage => _reqErrorMessage;
  bool? get reqIsLoading => _reqIsLoading;

  Stream<List<RequestService>> get requestsStream => _requestsController.stream;

  @override
  void dispose() {
    _requestsController.close();
    _subscription?.cancel();
    super.dispose();
  }

void cancelSubscription(){
    _subscription?.cancel();

}

  Future<void> getOngoingRequest(String senderEmail) async {
    _reqState = ResultState.loading;
    _reqErrorMessage = null;
    _reqIsLoading = true;
    notifyListeners();

    try {
      final carbageStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .where('senderEmail', isEqualTo: senderEmail)
          .where('isDone', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RequestService.fromFirestore(doc, null))
              .toList());

      final reportStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('report')
          .collection('items')
          .where('senderEmail', isEqualTo: senderEmail)
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

      _subscription = dataStream.listen((data) {
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

  Future<void> deleteRequest(RequestService request) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(request.senderEmail);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        await userRef.update({
          'services': FieldValue.arrayUnion([request.toFirestore()])
        });
      }

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(request.type == 1 ? 'carbage' : 'report')
          .collection('items')
          .doc(request.requestId)
          .delete();
      notifyListeners();
    } catch (error) {
      // print("Error deleting request: $error");
    }
  }
}
