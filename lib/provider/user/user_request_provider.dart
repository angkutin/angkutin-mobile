import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/state_enum.dart';
import '../../database/storage_service.dart';

class UserRequestProvider with ChangeNotifier {
  // final StorageService storageService;
  final StorageService storageService;
  UserRequestProvider(this.storageService);

  ResultState? _state;
  String? _errorMessage;
  bool? _isLoading = false;

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;
  bool? get isLoading => _isLoading;

  Future<void> createRequest({String? path, RequestService? requestService}) async {
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
  List<RequestService> _requests = [];
  StreamController<List<RequestService>> _requestsController = StreamController.broadcast();

  ResultState? get reqState => _reqState;
  String? get reqErrorMessage => _reqErrorMessage;
  bool? get reqIsLoading => _reqIsLoading;
  List<RequestService> get requests => _requests;

  Stream<List<RequestService>> get requestsStream => _requestsController.stream;

  @override
  void dispose() {
    _requestsController.close();
    super.dispose();
  }

  Future<void> getOngoingRequest(String senderEmail) async {
    _reqState = ResultState.loading;
    _reqErrorMessage = null;
    _reqIsLoading = true;
    notifyListeners();

    try {
      final dataStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .where('senderEmail', isEqualTo: senderEmail)
          .where('isDone', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RequestService.fromFirestore(doc, null))
              .toList());

      dataStream.listen((data) {
        _requests = data;
        _requestsController.add(data); // Add data to the stream
      });
      _reqState = ResultState.success;
    } catch (error) {
      _reqState = ResultState.error;
      _reqErrorMessage = error.toString();
      print("Errornya $_reqErrorMessage");
    } finally {
      _reqIsLoading = false;
      print("data permintaan : $_requests");
      notifyListeners();
    }
  }
}
