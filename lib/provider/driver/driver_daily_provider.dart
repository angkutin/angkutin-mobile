import 'package:angkutin/database/firestore_database.dart';
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

  Future<void> updateDriverDaily(
      String email, Map<String, dynamic> data) async {
    _isUpdateLoading = true;
    _updateState = ResultState.loading;
    notifyListeners();

    try {
      // Fetch the user document
      final userRef = FirebaseFirestore.instance.collection('users').doc(email);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        // Get the current value of "isDaily"
        _isDailyActive = userDoc.get('isDaily') ?? false;

        // Update data based on current value
        data['isDaily'] = _isDailyActive; // Toggle the value

        // Update the user document
        await updateUserData(email, data);
        _updateState = ResultState.success;
      } else {
        // Handle the case where the user document doesn't exist
        _updateErrorMessage =
            'Error: User document not found for email: $email';
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
