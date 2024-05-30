import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  Future<String> uploadImage(String collection, String docId, File image) async {
    final fileName = path.basename(image.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('$collection/$docId/$fileName');
    final uploadTask = storageRef.putFile(image);

    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
