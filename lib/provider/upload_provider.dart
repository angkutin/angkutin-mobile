import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

import '../common/state_enum.dart';
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

  // Future<String> uploadImage(String collection, String docId, File image) async {
  //   final fileName = path.basename(image.path);
  //   final storageRef =
  //       FirebaseStorage.instance.ref().child('$collection/$docId/$fileName');
  //   final uploadTask = storageRef.putFile(image);

  //   final snapshot = await uploadTask.whenComplete(() => {});
  //   final downloadUrl = await snapshot.ref.getDownloadURL();
  //   return downloadUrl;
  // }

  Future<void> uploadDataRegister({
    required String docId,
    required String fullName,
    required int activePhoneNumber,
    int? optionalPhoneNumber,
    required File image,
    required double latitude,
    required double longitude,
  }) async {
    _state = ResultState.loading;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await storageService.uploadImage("images",docId, image);

      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      await usersCollection.doc(docId).set(
          {
            'fullName': fullName,
            'activePhoneNumber': activePhoneNumber,
            'optionalPhoneNumber': optionalPhoneNumber,
            'imageUrl': imageUrl,
            'latitude': latitude,
            'longitude': longitude,
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
