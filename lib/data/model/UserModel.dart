// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? email;
  final String? name;
  final String? fullName;
  final String? address;
  final String? role;
  final String? imageUrl;
  final int? activePhoneNumber;
  final int? optionalPhoneNumber;
  final double? latitude;
  final double? longitude;
  final GeoPoint? lokasiPetugas;
  // final DateTime createdAt;

  User({
     this.email,
     this.name,
    this.fullName,
    this.address,
    this.role,
    this.imageUrl,
    this.activePhoneNumber,
    this.optionalPhoneNumber,
    this.latitude,
    this.longitude,
    this.lokasiPetugas
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String?,
      name: json['name'] as String?,
      fullName: json['fullName'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String?,
      imageUrl: json['imageUrl'] as String?,
      activePhoneNumber: json['activePhoneNumber'] as int?,
      optionalPhoneNumber: json['optionalPhoneNumber'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      lokasiPetugas: json['lokasiPetugas'] as GeoPoint?,
      // createdAt: json['created_at'] is DateTime ? json['created_at'] : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'fullName': fullName,
      'address': address,
      'role': role,
      'imageUrl': imageUrl,
      'activePhoneNumber': activePhoneNumber,
      'optionalPhoneNumber': optionalPhoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'lokasiPetugas': lokasiPetugas,
      // 'createdAt': createdAt,
    };
  }
}
