import 'dart:async';
import 'package:flutter/material.dart';

import '../../common/state_enum.dart';
import '../../data/model/UserModel.dart';
import '../../database/firestore_database.dart';

class UserDailyProvider with ChangeNotifier {
  ResultState? _state;
  String? _errorMessage;
  final StreamController<User> _userDataController = StreamController.broadcast();

  ResultState? get state => _state;
  String? get errorMessage => _errorMessage;

  Stream<User> get dataStream => _userDataController.stream;

  @override
  void dispose() {
    _userDataController.close();
    _driverDataController.close();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> getUserStream(String email) async {
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = db.collection("users").doc(email);
      docRef.snapshots().listen(
          (event) {
        _userDataController.add(User.fromSnapshot(event));
        _state = ResultState.success;
      }, onError: (error) {
        _state = ResultState.error;
        _errorMessage = error.toString();
      });
    } finally {
      notifyListeners();
    }
  }

  final StreamController<List<User>> _driverDataController =
      StreamController.broadcast();
  StreamSubscription? _subscription;

  Stream<List<User>> get driverDataStream => _driverDataController.stream;

  Future<void> getDailyDriverAvailable(String kecamatan) async {
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = db
          .collection("users")
          .where("role", whereIn: ["Petugas", "petugas"])
          .where("address", isEqualTo: kecamatan)
          .where("isDaily", isEqualTo: true);

      _subscription = docRef.snapshots().listen((event) {
        List<User> drivers = event.docs.map((doc) => User.fromSnapshot(doc)).toList();
        _driverDataController.add(drivers);
        _state = ResultState.success;
      }, onError: (error) {
        _state = ResultState.error;
        _errorMessage = error.toString();
      });
    } finally {
      notifyListeners();
    }
  }
}
