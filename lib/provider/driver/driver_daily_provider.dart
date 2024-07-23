import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/state_enum.dart';

class DriverDailyProvider with ChangeNotifier {
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
        _updateErrorMessage =
            'Error: User document not found for email: $email';
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

  ResultState? _massUpdateState;
  String? _massUpdateErrorMessage;
  bool? _isMassUpdateLoading;

// Getters
  ResultState? get massUpdateState => _massUpdateState;
  String? get massUpdateErrorMessage => _massUpdateErrorMessage;
  bool? get isMassUpdateLoading => _isMassUpdateLoading;

  Future<void> updateMassDailyUsers(String kecamatan, bool value) async {
    _isMassUpdateLoading = true;
    _updateState = ResultState.loading;
    notifyListeners();

    try {
      // Query untuk mendapatkan semua pengguna yang memiliki alamat sesuai dengan kecamatan
      final userQuery = FirebaseFirestore.instance
          .collection('users')
          .where("role", whereIn: ["Masyarakat", "masyarakat"]).where('address',
              isEqualTo: kecamatan);

      // Dapatkan dokumen pengguna
      final userSnapshot = await userQuery.get();

      // Jika ada dokumen pengguna yang ditemukan, lakukan pembaruan dalam batch
      if (userSnapshot.docs.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in userSnapshot.docs) {
          final currentData = doc.data();

          if (currentData['isDaily'] != value) {
            // Only update if there is a change
            batch.update(doc.reference, {'isDaily': value});
          }
        }

        // Commit batch update
        await batch.commit();

        // _isDailyActive = value;
        _massUpdateErrorMessage = null;
        _massUpdateState = ResultState.success;
      } else {
        // Tangani kasus di mana tidak ada pengguna yang ditemukan
        _massUpdateErrorMessage = 'Error: No users found in $kecamatan';
        _massUpdateState = ResultState.error;
      }
    } catch (e) {
      _massUpdateState = ResultState.error;
      _massUpdateErrorMessage = e.toString();
    } finally {
      _isMassUpdateLoading = false;
      notifyListeners();
    }
  }
}
