import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/model/UserModel.dart' as user_model;
import '../../../database/firestore_database.dart';

Future<user_model.User> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  if (googleAuth == null) {
    throw Exception('Google authentication failed');
  }

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

  if (userCredential.user != null) {
    final String email = userCredential.user!.email!;
    // get or ceate user
    final firebaseUser = await getUserFromFirebaseOrCreateNewUser(email);
    if (firebaseUser != null) {
      return firebaseUser;
    } else {
      // print('Error: Unable to get or create user data for email: $email');
      throw Exception('Error: Unable to get or create user data for email: $email');
    }
  } else {
    throw Exception('User authentication failed');
  }
}
