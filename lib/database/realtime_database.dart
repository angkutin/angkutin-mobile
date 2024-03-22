import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseDatabase database = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://angkutin-7fc40-default-rtdb.asia-southeast1.firebasedatabase.app/'
);

final User? user = auth.currentUser;

Future<void> saveUserData(String name, String email, String role) async {
  final uid = auth.currentUser?.uid;
  // Buat map data user
  final data = {
    'name': name,
    'email': email,
    'role': role,
  };


  await database.ref().child('users/$uid').set(data);

}
