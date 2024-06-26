// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? email;
  final String? name;
  final String? fullName;
  final bool? isDaily;
  final String? address;
  final String? role;
  final String? imageUrl;
  final int? activePhoneNumber;
  final int? optionalPhoneNumber;
  final double? latitude;
  final double? longitude;
  final GeoPoint? lokasiPetugas;
  final List? services;
  // final DateTime createdAt;

  User(
      {this.email,
      this.name,
      this.fullName,
      this.isDaily,
      this.address,
      this.role,
      this.imageUrl,
      this.activePhoneNumber,
      this.optionalPhoneNumber,
      this.latitude,
      this.longitude,
      this.lokasiPetugas,
      this.services});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        email: json['email'] as String?,
        name: json['name'] as String?,
        fullName: json['fullName'] as String?,
        isDaily: json['isDaily'] as bool?,
        address: json['address'] as String?,
        role: json['role'] as String?,
        imageUrl: json['imageUrl'] as String?,
        activePhoneNumber: json['activePhoneNumber'] as int?,
        optionalPhoneNumber: json['optionalPhoneNumber'] as int?,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        lokasiPetugas: json['lokasiPetugas'] as GeoPoint?,
        services: json['services'] as List?
        // createdAt: json['created_at'] is DateTime ? json['created_at'] : DateTime.now(),
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'fullName': fullName,
      'isDaily': isDaily,
      'address': address,
      'role': role,
      'imageUrl': imageUrl,
      'activePhoneNumber': activePhoneNumber,
      'optionalPhoneNumber': optionalPhoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'lokasiPetugas': lokasiPetugas,
      'services': services
      // 'createdAt': createdAt,
    };
  }

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
        email: snapshot.id,
        name: data['name'], // Assuming name exists in Firestore
        fullName: data['fullName'], // Assuming fullName exists in Firestore
        isDaily: data['isDaily'],
        address: data['address'] as String?,
        role: data['role'] as String?,
        imageUrl: data['imageUrl'] as String?,
        activePhoneNumber: data['activePhoneNumber'] as int?,
        optionalPhoneNumber: data['optionalPhoneNumber'] as int?,
        latitude: data['latitude'] as double?,
        longitude: data['longitude'] as double?,
        lokasiPetugas: data['lokasiPetugas'] as GeoPoint?,
        services: data['services'] as List?);
  }

// untuk simpan lokal saja
  Map<String, dynamic> toMinimalJson() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'fullName': fullName,
      'address': address,
      'imageUrl': imageUrl,
      'activePhoneNumber': activePhoneNumber,
      'optionalPhoneNumber': optionalPhoneNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
