import 'dart:async';

import 'package:angkutin/database/firestore_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/state_enum.dart';
import '../../data/model/UserModel.dart';

class DriverDailyProvider with ChangeNotifier {
  // ResultState? _state;
  // String? _errorMessage;
  // StreamController<User> _userDataController = StreamController.broadcast();

  // ResultState? get state => _state;
  // String? get errorMessage => _errorMessage;

  // Stream<User> get dataStream => _userDataController.stream;

  // @override
  // void dispose() {
  //   _userDataController.close();
  //   super.dispose();
  // }

  // Future<void> getDriverDailyStatus(String email) async {
  //   _state = ResultState.loading;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     final query = db
  //         .collection("users")
  //         .where("role", isEqualTo: "Petugas"); // Create a query

  //     // Fetch query results
  //     query.snapshots().listen((querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         if (doc.id == email) {
  //           _userDataController.add(User.fromSnapshot(doc));
  //           _state = ResultState.success;
  //           break;
  //         }
  //       }
  //     }, onError: (error) {
  //       print("Listen failed: $error");
  //       _state = ResultState.error;
  //       _errorMessage = error.toString();
  //       print("Error: $_errorMessage");
  //     });
  //   } finally {
  //     print("user daily diget");
  //     notifyListeners();
  //   }
  // }
ResultState? _updateState;
  String? _updateErrorMessage;
  bool? _isUpdateLoading;
  bool? _isDailyActive;

  // Getters
  ResultState? get updateState => _updateState;
  String? get updateErrorMessage => _updateErrorMessage;
  bool? get isUpdateLoading => _isUpdateLoading;
  bool? get isDailyActive => _isDailyActive;

  Future<void> updateDriverDaily(String email, bool value) async {
    _isUpdateLoading = true;
    _updateState = ResultState.loading;
    notifyListeners();

    try {
      // Referensi ke dokumen pengguna
      final userRef = FirebaseFirestore.instance.collection('users').doc(email);

      // Cek apakah dokumen pengguna ada
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        // Update nilai isDaily
        await userRef.update({'isDaily': value});
        
        _isDailyActive = value;
        _updateState = ResultState.success;
      } else {
        // Tangani kasus di mana dokumen pengguna tidak ditemukan
        _updateErrorMessage = 'Error: User document not found for email: $email';
        _updateState = ResultState.error;
      }
    } catch (e) {
      _updateState = ResultState.error;
      _updateErrorMessage = e.toString();
    } finally {
      _isUpdateLoading = false;
      notifyListeners();
    }
  }
}
