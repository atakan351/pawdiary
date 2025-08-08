import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';

class PetService {
  final CollectionReference petsCollection = FirebaseFirestore.instance
      .collection('pets');

  Future<void> addPet(Pet pet) async {
    await petsCollection.add(pet.toMap());
  }

  Stream<List<Pet>> getPetsForUser(String userId) {
    return petsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Pet.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
