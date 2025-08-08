import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String userId;
  final String? petId;
  final String title;
  final String description;
  final DateTime date;
  final String time; // Format: "14:30"
  final String
      type; // 'vaccine', 'vet', 'medicine', 'food', 'grooming', 'other'
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    this.petId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromFirestore(Map<String, dynamic> data, String id) {
    return Reminder(
      id: id,
      userId: data['userId'] ?? '',
      petId: data['petId'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '09:00',
      type: data['type'] ?? 'other',
      priority: data['priority'] ?? 'medium',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'petId': petId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'type': type,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? petId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? type,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  String get formattedDateTime {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} - $time';
  }

  String get typeDisplayName {
    switch (type) {
      case 'vaccine':
        return 'Aşı';
      case 'vet':
        return 'Veteriner';
      case 'medicine':
        return 'İlaç';
      case 'food':
        return 'Beslenme';
      case 'grooming':
        return 'Bakım';
      default:
        return 'Diğer';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case 'high':
        return 'Yüksek';
      case 'medium':
        return 'Orta';
      case 'low':
        return 'Düşük';
      default:
        return 'Orta';
    }
  }
}
