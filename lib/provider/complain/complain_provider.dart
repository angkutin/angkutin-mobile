import 'dart:async';
import 'package:angkutin/data/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/state_enum.dart';

class ComplainProvider extends ChangeNotifier {
  ResultState? _state;
  String? _errorMessage;
  bool? _isLoading = false;

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;
  bool? get isLoading => _isLoading;

  Future<void> sendComplain(
      User user, String complaintId, String titleComplain, String contentComplain, DateTime time, String? imgUrl) async {
    _state = ResultState.loading;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final CollectionReference requestsCollection = FirebaseFirestore.instance.collection('complaints');

      await requestsCollection
          .doc(complaintId)
          .set({
            'senderEmail' : user.email,
            'senderName': user.fullName,
            'role': user.role,
            'address' : user.address,
            'activePhoneNumber':user.activePhoneNumber,
            'optionalPhoneNumber':user.optionalPhoneNumber,

            'title' : titleComplain,
            'description' : contentComplain,
            'imageUrl' : imgUrl,

            'isDone': false,

            'time': time
          });

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
