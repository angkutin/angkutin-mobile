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
    notifyListeners();

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
    final userDataString = jsonEncode(userData.toMinimalJson());
    prefs.setString(userDataKey, userDataString);
  }

  Future<String?> readUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userDataKey);

    if (userDataString != null) {
      final userDataMap = json.decode(userDataString);
      _userData = user_model.User.fromJson(userDataMap);
      print("membaca data local provider : ${userDataString}");

      notifyListeners();
    }

    return userDataString;
  }

  Future<void> deleteUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userDataKey);
    _userData = null;
    notifyListeners();
  }

// save onboarding state
  final String onBoardingKey = 'onboarding_key';

  Future<void> saveOnBoardingState(bool state) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(onBoardingKey, state);
  }

  Future<bool> getOnBoardingState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onBoardingKey) ?? false;
  }

// save login state
  final String loginKey = 'login_key';

  Future<void> saveLoginState(bool state) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(loginKey, state);
  }

  Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey) ?? false;
  }

// save login state
  final String roleKey = 'role_key';

  // Save role state to shared preferences
  Future<void> saveRoleState(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(roleKey, role);
  }

  // Get role state from shared preferences
  Future<String> getRoleState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey) ?? "None";
  }

  Future<void> deleteRoleLocally() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(roleKey);
    notifyListeners();
  }

}
