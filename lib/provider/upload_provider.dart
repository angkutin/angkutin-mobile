import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../common/state_enum.dart';
import '../data/model/RequestModel.dart';
import '../database/storage_service.dart';

class UploadProvider with ChangeNotifier {
  final StorageService storageService;
  UploadProvider(this.storageService);

  ResultState? _state;
  String? _errorMessage;
  bool? _isLoading = false;

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;
  bool? get isLoading => _isLoading;

  String? _imageUrl;
  String? get imageUrl => _imageUrl; 

  Future<void> uploadDataRegister({
    required String docId,
    required String fullName,
    required bool isDaily,
    required int activePhoneNumber,
    required String address,
    int? optionalPhoneNumber,
    required File image,
    required double latitude,
    required double longitude,
    required List<RequestService> services
  }) async {
    _state = ResultState.loading;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      _imageUrl = await storageService.uploadImage("images", docId, image);

      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      await usersCollection.doc(docId).set(
          {
            'fullName': fullName,
            'isDaily': isDaily,
            'address':address, 
            'activePhoneNumber': activePhoneNumber,
            'optionalPhoneNumber': optionalPhoneNumber,
            'imageUrl': _imageUrl,
            'latitude': latitude,
            'longitude': longitude,
            'services': services
          },
          SetOptions(
              merge:
                  true)); // agar menambah atribut tanpa menghapus yang sudah ada

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
