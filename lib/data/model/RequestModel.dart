// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestService {
  final String requestId; // Added requestId for unique identification
  final String userId;
  final String name;
  final Timestamp date;
  final String? description;
  final String imageUrl;
  final GeoPoint userLoc;
  final int type;
  final bool isDelivered;
  final bool isDone;

  RequestService({
    required this.requestId, // Optional requestId constructor parameter
    required this.userId,
    required this.name,
    required this.date,
    this.description,
    required this.imageUrl,
    required this.userLoc,
    required this.type,
    required this.isDelivered,
    required this.isDone,
  });

  factory RequestService.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return RequestService(
      requestId: data?['requestId'] as String, // Added requestId
      userId: data?['userId'] as String,
      name: data?['name'] as String,
      date: data?['date'] as Timestamp,
      description: data?['description'] as String?,
      imageUrl: data?['imageUrl'] as String,
      userLoc: data?['userLoc'] as GeoPoint,
      type: data?['type'] as int,
      isDelivered: data?['isDelivered'] as bool,
      isDone: data?['isDone'] as bool,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId, // Added requestId
      'userId': userId,
      'name': name,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
      'userLoc': userLoc,
      'type': type,
      'isDelivered': isDelivered,
      'isDone': isDone,
    };
  }
}
