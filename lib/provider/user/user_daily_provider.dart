import 'dart:async';
import 'package:flutter/material.dart';

import '../../common/state_enum.dart';
import '../../data/model/UserModel.dart';
import '../../database/firestore_database.dart';

class UserDailyProvider with ChangeNotifier {
  ResultState? _state;
  String? _errorMessage;
  StreamController<User> _userDataController = StreamController.broadcast();

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;

  Stream<User> get dataStream => _userDataController.stream;

  @override
  void dispose() {
    _userDataController.close();
    _driverDataController.close();
    super.dispose();
  }

  Future<void> getUserStream(String email) async {
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = db.collection("users").doc(email);
      docRef.snapshots().listen(
          // (event) => print("current data: ${event.data()}"),
          (event) {
        _userDataController.add(User.fromSnapshot(event));
        _state = ResultState.success;
        print("current data: ${event.data()}");
      }, onError: (error) {
        print("Listen failed: $error");
        _state = ResultState.error;
        _errorMessage = error.toString();
        print("Errornya $_errorMessage");
      });
    } finally {
      print("user daily diget");
      notifyListeners();
    }
  }

  StreamController<List<User>> _driverDataController =
      StreamController.broadcast();
  Stream<List<User>> get driverDataStream => _driverDataController.stream;

  Future<void> getDailyDriverAvailable(String kecamatan) async {
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = db
          .collection("users")
          .where("role", isEqualTo: "Petugas")
          .where("address", isEqualTo: kecamatan)
          .where("isDaily", isEqualTo: true);

      docRef.snapshots().listen((event) {
        List<User> drivers =
            event.docs.map((doc) => User.fromSnapshot(doc)).toList();

        print("Jumlah driver: ${drivers.length}");

        _driverDataController.add(drivers);
        _state = ResultState.success;
      }, onError: (error) {
        print("Listen failed: $error");
        _state = ResultState.error;
        _errorMessage = error.toString();
        print("Errornya $_errorMessage");
      });
    } finally {
      notifyListeners();
    }
  }
}
