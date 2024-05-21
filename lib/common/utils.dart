import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

double mediaQueryWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;
double mediaQueryHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;

// show snackbar
void showInfoSnackbar(BuildContext context, String message) {
  if (message.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

// compress file
Future<File?> compressImage(File imageFile, int maxSizeKB) async {
  final int maxSizeBytes = maxSizeKB * 1024;

  List<int> imageBytes = await imageFile.readAsBytes();
  int currentSize = imageBytes.length;

  if (currentSize <= maxSizeBytes) {
    return imageFile;
  }

  int quality = (maxSizeBytes / currentSize * 100).floor();

  try {
    Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      Uint8List.fromList(imageBytes),
      quality: quality,
    );

    // Dapatkan direktori aplikasi
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // Buat file sementara untuk menyimpan gambar yang sudah dikompresi
    String compressedFilePath =
        '$appDocPath/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    File compressedFile =
        await File(compressedFilePath).writeAsBytes(compressedBytes);

    return compressedFile;
  } catch (error) {
    print('Error compressing image: $error');
    return null;
  }
}

Future<bool> storagePermission(Permission permission) async {
  final DeviceInfoPlugin info =
      DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  final AndroidDeviceInfo build = await info.androidInfo;

  if (build.version.sdkInt >= 30) {
    var rp = await Permission.manageExternalStorage.request();
    if (rp.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

// Image Service
class ImageService {
  File? image;
  Future<File?> pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imagePicked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imagePicked != null) {
      File originalImage = File(imagePicked.path);
      File? compressedImage = await compressImage(originalImage, 800);

      if (compressedImage != null) {
        image = File(compressedImage.path);
        int imageSize = await image!.length();
        int originalImageSize = await originalImage.length();

        print('Image Size Original: ${originalImageSize} bytes');
        print('Image Size Compressed: $imageSize bytes');
      } else {
        print("Image picking canceled");
      }
    }
    return null;
  }
}




