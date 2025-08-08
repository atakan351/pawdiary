import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final CollectionReference notesCollection = FirebaseFirestore.instance
      .collection('notes');

  Future<void> addNote(Note note) async {
    await notesCollection.add(note.toMap());
  }

  Stream<List<Note>> getNotesForUser(String userId) {
    return notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Note.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }
}
