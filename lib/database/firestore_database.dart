import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/model/UserModel.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

Future<User?> getUserFromFirebaseOrCreateNewUser(String email) async {
  // Check if user exists in Firestore
  final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(email).get();

  if (userDocSnapshot.exists) {
    final Map<String, dynamic>? userData = userDocSnapshot.data();

    if (userData != null) {
      return User.fromJson(userData);
    } else {
      return null; // Handle error: unable to retrieve user data
    }
  } else {
    // User doesn't exist, create new user and return data
    final String userId = email; // Assuming email is the unique identifier
    final String name = email.split('@')[0]; // Extract name from email

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'email': email,
      'name': name,
      'role': "Masyarakat",
    });

    final Map<String, dynamic> newUser = {
      'email': email,
      'name': name,
      'role': "Masyarakat",
    };

    return User.fromJson(newUser);
  }
}

Future<void> updateUserData(String email, Map<String, dynamic> data) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection("users").doc(email);
  try {
    await docRef.update(data);
  } catch (e) {
    print(e);
  }
}
