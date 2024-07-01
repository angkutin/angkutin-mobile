// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestService {
  final String requestId; // Added requestId for unique identification
  final String senderEmail;
  final String name;
  final Timestamp date;
  final String? description;
  final String imageUrl;
  final GeoPoint userLoc;
  final int type;
  final bool isDelivered;
  final bool isAcceptByDriver;
  final bool isDone;
  final String wilayah;
  String? namaPetugas;
  GeoPoint? lokasiPetugas;
  String? idPetugas;

  String? tipePermintaanAngkutan;
  int? biayaPengangkutan;
  bool? isPaying;

  RequestService(
      {required this.requestId, // Optional requestId constructor parameter
      required this.senderEmail,
      required this.name,
      required this.date,
      this.description,
      required this.imageUrl,
      required this.userLoc,
      required this.type,
      required this.isDelivered,
      required this.isAcceptByDriver,
      required this.isDone,
      required this.wilayah,
      this.namaPetugas,
      this.lokasiPetugas,
      this.idPetugas,

      this.tipePermintaanAngkutan,
      this.biayaPengangkutan,
      this.isPaying
      });

  factory RequestService.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return RequestService(
      requestId: data?['requestId'] as String, // Added requestId
      senderEmail: data?['senderEmail'] as String,
      name: data?['name'] as String,
      date: data?['date'] as Timestamp,
      description: data?['description'] as String?,
      imageUrl: data?['imageUrl'] as String,
      userLoc: data?['userLoc'] as GeoPoint,
      type: data?['type'] as int,
      isDelivered: data?['isDelivered'] as bool,
      isAcceptByDriver: data?['isAcceptByDriver'] as bool,
      isDone: data?['isDone'] as bool,
      wilayah: data?['wilayah'] as String,
      namaPetugas: data?['namaPetugas'],
      lokasiPetugas: data?['lokasiPetugas'],
      idPetugas: data?['idPetugas'],
      tipePermintaanAngkutan: data?['tipePermintaanAngkutan'],
      biayaPengangkutan: data?['biayaPengangkutan'],
      isPaying: data?['isPaying']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId, // Added requestId
      'senderEmail': senderEmail,
      'name': name,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
      'userLoc': userLoc,
      'type': type,
      'isDelivered': isDelivered,
      'isAcceptByDriver': isAcceptByDriver,
      'isDone': isDone,
      'wilayah': wilayah,
      'namaPetugas': namaPetugas,
      'lokasiPetugas': lokasiPetugas,
      'idPetugas': idPetugas,
      'tipePermintaanAngkutan': tipePermintaanAngkutan,
      'biayaPengangkutan': biayaPengangkutan,
      'isPaying': isPaying
    };
  }
}

