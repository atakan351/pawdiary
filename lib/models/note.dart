import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String userId;
  final String? petId;
  final DateTime date;
  final String description;
  final String? photoBase64;

  Note({
    required this.id,
    required this.userId,
    this.petId,
    required this.date,
    required this.description,
    this.photoBase64,
  });

  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      userId: map['userId'] ?? '',
      petId: map['petId'],
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      photoBase64: map['photoBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'petId': petId,
      'date': date,
      'description': description,
      'photoBase64': photoBase64,
    };
  }
}
