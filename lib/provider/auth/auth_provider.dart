import 'dart:convert';

import 'package:angkutin/database/firestore_database.dart';
import 'package:angkutin/screen/auth/service/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/model/UserModel.dart' as user_model;
import '../../common/state_enum.dart';

class AuthenticationProvider with ChangeNotifier {
  ResultState? _state;
  user_model.User? _userData;
  String? _errorMessage;
  bool? _isLoading;

  // Getters
  ResultState? get state => _state;
  user_model.User? get currentUser => _userData;
  String? get errorMessage => _errorMessage;
  bool? get isLoading => _isLoading;

  Future<void> signInWithGoogleProv() async {
    _state = ResultState.loading;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await signInWithGoogle();
      _userData = user;
      await saveUserDataLocally(user);

      _state = ResultState.success;
      notifyListeners();
    } on Exception catch (error) {
      _state = ResultState.error;
      _errorMessage = error.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      print("Provider : current user : ${_userData}");
    }
  }

  ResultState? _updateState;
  String? _updateErrorMessage;
  bool? _isUpdateLoading;

  // Getters
  ResultState? get updateState => _updateState;
  String? get updateErrorMessage => _updateErrorMessage;
  bool? get isUpdateLoading => _isUpdateLoading;

  Future<void> updateUserDataProv(
      String email, Map<String, dynamic> data) async {
    _isUpdateLoading = true;
    _updateState = ResultState.loading;
    try {
      await updateUserData(email, data);
      _updateState = ResultState.success;
      notifyListeners();
    } catch (e) {
      _updateState = ResultState.error;
      _updateErrorMessage = e.toString();
      notifyListeners();
    } finally {
      _isUpdateLoading = false;
    }
  }

// save user data to local
  final String userDataKey = 'user_data';

  Future<void> saveUserDataLocally(user_model.User userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = jsonEncode(userData.toJson());
    prefs.setString(userDataKey, userDataString);
    print("berhasil simpan data ke local : ${jsonDecode(userDataString)}");
  }

  Future<void> readUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userDataKey);

    if (userDataString != null) {
      final userDataMap = json.decode(userDataString);
      _userData = user_model.User.fromJson(userDataMap);
      print("membaca data local : $_userData");

      notifyListeners();
    }
  }

  Future<void> deleteUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userDataKey);
    _userData = null;
    print("user data deleted locally");
    notifyListeners();
  }
}
