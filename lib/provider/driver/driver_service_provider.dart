import 'dart:async';
import 'package:angkutin/data/model/RequestModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/state_enum.dart';
import '../../database/storage_service.dart';

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

  Future<void> acceptUserRequest(
      String reqId, String namaPetugas, GeoPoint driverLoc) async {
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
          'namaPetugas': namaPetugas, // NTAR TAMBAHIN EMAIL PETUGAS
          'lokasiPetugas': driverLoc,
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
}
