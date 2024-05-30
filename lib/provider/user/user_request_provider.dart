import 'dart:io';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

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



  Future<void> createRequest({
    RequestService? requestService
  }) async {
    _state = ResultState.loading;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      // untuk gamabr dilakukan di ui, provider menerima url aja utk diinput ke firestore
      // final imageUrl = await storageService.uploadImage("docId", image);
      final now = DateTime.now();
      final formattedDate = now.toString().split(' ')[0]; // Get the date part only


      final CollectionReference requestsCollection  = FirebaseFirestore.instance
      .collection('requests')
      .doc('carbage')
      .collection(formattedDate);


      await requestsCollection .doc(requestService?.requestId).set(
        requestService?.toFirestore()
      );

      _state = ResultState.success;
    } catch (error) {
      _state = ResultState.error;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
