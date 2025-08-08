class Veterinarian {
  final String id;
  final String userId;
  final String name;
  final String clinicName;
  final String phone;
  final String email;
  final String address;
  final String specialization;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Veterinarian({
    required this.id,
    required this.userId,
    required this.name,
    required this.clinicName,
    required this.phone,
    required this.email,
    required this.address,
    required this.specialization,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore'dan veri okuma
  factory Veterinarian.fromFirestore(Map<String, dynamic> data, String id) {
    return Veterinarian(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      clinicName: data['clinicName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      specialization: data['specialization'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'clinicName': clinicName,
      'phone': phone,
      'email': email,
      'address': address,
      'specialization': specialization,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Kopya oluşturma
  Veterinarian copyWith({
    String? id,
    String? userId,
    String? name,
    String? clinicName,
    String? phone,
    String? email,
    String? address,
    String? specialization,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Veterinarian(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      clinicName: clinicName ?? this.clinicName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      specialization: specialization ?? this.specialization,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
