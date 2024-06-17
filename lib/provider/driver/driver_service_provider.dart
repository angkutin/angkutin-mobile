import 'dart:async';
import 'dart:ffi';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/state_enum.dart';

class DriverServiceProvider with ChangeNotifier {
// get request
  ResultState? _reqState;
  String? _reqErrorMessage;
  bool? _reqIsLoading = false;
  StreamController<List<RequestService>> _requestsController =
      StreamController.broadcast();

  ResultState? get reqState => _reqState;
  String? get reqErrorMessage => _reqErrorMessage;
  bool? get reqIsLoading => _reqIsLoading;
  // List<RequestService> get requests => _requests;

  Stream<List<RequestService>> get requestsStream => _requestsController.stream;

  @override
  void dispose() {
    _requestsController.close();
    super.dispose();
  }

  Future<void> getCarbageRequestFromUser(String kecamatan) async {
    _reqState = ResultState.loading;
    _reqErrorMessage = null;
    _reqIsLoading = true;
    notifyListeners();

    try {
      final dataStream = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .where('wilayah', isEqualTo: kecamatan)
          .where('isAcceptByDriver', isEqualTo: false)
          .where('isDone', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RequestService.fromFirestore(doc, null))
              .toList());

      dataStream.listen((data) {
        // _requests = data;
        _requestsController.add(data); // Add data to the stream
      });
      _reqState = ResultState.success;
    } catch (error) {
      _reqState = ResultState.error;
      _reqErrorMessage = error.toString();
      print("Errornya $_reqErrorMessage");
    } finally {
      _reqIsLoading = false;
      notifyListeners();
    }
  }

  ResultState? _servState;
  String? _servErrorMessage;
  bool? _servIsLoading = false;
  // StreamController<List<RequestService>> _requestsController = StreamController.broadcast();

  ResultState? get servState => _servState;
  String? get servErrorMessage => _servErrorMessage;
  bool? get servIsLoading => _servIsLoading;

  Future<void> acceptUserRequest(String reqId, String namaPetugas,
      String idPetugas, GeoPoint driverLoc) async {
    _servState = ResultState.loading;
    _servErrorMessage = null;
    _servIsLoading = true;
    notifyListeners();

    try {
      final requestRef = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .doc(reqId);

      final requestDoc = await requestRef.get();
      if (requestDoc.exists) {
        // acc dari sisi user
        await requestRef.update({
          'isAcceptByDriver': true,
          'namaPetugas': namaPetugas,
          'lokasiPetugas': null,
          'idPetugas': idPetugas
        });
      }

      _servState = ResultState.success;
    } catch (error) {
      _servState = ResultState.error;
      _servErrorMessage = error.toString();
      print("Errornya $_servErrorMessage");
    } finally {
      _servIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDriverLocation(String reqId, GeoPoint driverLoc) async {
    try {
      final requestRef = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .doc(reqId);

      final requestDoc = await requestRef.get();
      if (requestDoc.exists) {
        final isDone = requestDoc.data()?['isDone'] as bool?;
        if (isDone == false) {
          await requestRef.update({
            'lokasiPetugas': driverLoc,
          });
          print("Lokasi Driver diupdate !");
        }
      }
    } catch (error) {
      print("Error updating driver location: $error");
    }
  }

  ResultState? _finishState;
  bool? _finishIsLoading = false;

  ResultState? get finishState => _finishState;
  bool? get finishIsLoading => _finishIsLoading;

  Future<void> finishUserRequest(
      String reqId, String userId, String petugasId) async {
    _finishState = ResultState.loading;
    // _servErrorMessage = null;
    _finishIsLoading = true;
    notifyListeners();
    try {
      final requestRef = FirebaseFirestore.instance
          .collection('requests')
          .doc('carbage')
          .collection('items')
          .doc(reqId);

      final requestDoc = await requestRef.get();

      // mengubah state isDone
      if (requestDoc.exists) {
        final isDone = requestDoc.data()?['isDone'] as bool?;
        if (isDone == false) {
          await requestRef.update({
            'isDone': true,
          });
          print("Permintaan sudah selesai");
        }
      }

      // tambahin ke riwayat user
      final requestData = requestDoc.data();

      if (requestData != null) {
        final selectedData = {
          'description': requestData['description'],
          'name': requestData['name'],
          'senderEmail': requestData['senderEmail'],
          'idPetugas': requestData['idPetugas'],
          'imageUrl': requestData['imageUrl'],
          'namaPetugas': requestData['namaPetugas'],
          'requestId': requestData['requestId'],
          'type': requestData['type'],
          'wilayah': requestData['wilayah'],
        };

        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          await userRef.update({
            'services': FieldValue.arrayUnion([selectedData])
          });
        }

        // tambahin ke riwayat driver
        final petugasRef =
            FirebaseFirestore.instance.collection('users').doc(petugasId);
        final petugasDoc = await petugasRef.get();
        if (petugasDoc.exists) {
          await petugasRef.update({
            'services': FieldValue.arrayUnion([selectedData])
          });
        }
      }

      // hapus dari path asli
      requestRef.delete();

      _finishState = ResultState.success;
    } catch (error) {
      _finishState = ResultState.error;

      print("Error menyelesaikan permintaan: $error");
    } finally {
      _finishIsLoading = false;
      notifyListeners();
    }
  }
}
