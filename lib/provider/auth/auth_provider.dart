

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthenticationProvider with ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthenticationProvider() {
    _currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners(); // Notify listeners of user changes
    });
  }

  bool isLoggedIn() => _currentUser != null;
}