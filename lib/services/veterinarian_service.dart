import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veterinarian.dart';

class VeterinarianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'veterinarians';

  // Veteriner ekleme
  Future<void> addVeterinarian(Veterinarian veterinarian) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(
            veterinarian
                .copyWith(
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                )
                .toFirestore(),
          );

      // ID'yi güncelle
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception('Veteriner eklenirken hata oluştu: $e');
    }
  }

  // Kullanıcının veterinerlerini getirme
  Stream<List<Veterinarian>> getVeterinariansForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Veterinarian.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Veteriner güncelleme
  Future<void> updateVeterinarian(Veterinarian veterinarian) async {
    try {
      await _firestore.collection(_collection).doc(veterinarian.id).update(
            veterinarian.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Veteriner güncellenirken hata oluştu: $e');
    }
  }

  // Veteriner silme
  Future<void> deleteVeterinarian(String veterinarianId) async {
    try {
      await _firestore.collection(_collection).doc(veterinarianId).delete();
    } catch (e) {
      throw Exception('Veteriner silinirken hata oluştu: $e');
    }
  }

  // Tek veteriner getirme
  Future<Veterinarian?> getVeterinarian(String veterinarianId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(veterinarianId).get();

      if (doc.exists) {
        return Veterinarian.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Veteriner getirilirken hata oluştu: $e');
    }
  }

  // Veteriner arama
  Stream<List<Veterinarian>> searchVeterinarians(String userId, String query) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Veterinarian.fromFirestore(doc.data(), doc.id))
          .where((vet) =>
              vet.name.toLowerCase().contains(query.toLowerCase()) ||
              vet.clinicName.toLowerCase().contains(query.toLowerCase()) ||
              vet.specialization.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
