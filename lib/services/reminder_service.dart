import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reminders';

  // Hatırlatıcı ekleme
  Future<void> addReminder(Reminder reminder) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(
            reminder
                .copyWith(
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                )
                .toFirestore(),
          );

      // ID'yi güncelle
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception('Hatırlatıcı eklenirken hata oluştu: $e');
    }
  }

  // Kullanıcının hatırlatıcılarını getirme
  Stream<List<Reminder>> getRemindersForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromFirestore(doc.data(), doc.id);
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  // Bugünkü hatırlatıcıları getirme
  Stream<List<Reminder>> getTodayRemindersForUser(String userId) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('date', isLessThan: Timestamp.fromDate(todayEnd))
        .orderBy('date')
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Yaklaşan hatırlatıcıları getirme (gelecek 7 gün)
  Stream<List<Reminder>> getUpcomingRemindersForUser(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 8));

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('date', isLessThan: Timestamp.fromDate(nextWeek))
        .orderBy('date')
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Hatırlatıcı güncelleme
  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _firestore.collection(_collection).doc(reminder.id).update(
            reminder.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Hatırlatıcı güncellenirken hata oluştu: $e');
    }
  }

  // Hatırlatıcı silme
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection(_collection).doc(reminderId).delete();
    } catch (e) {
      throw Exception('Hatırlatıcı silinirken hata oluştu: $e');
    }
  }

  // Hatırlatıcıyı tamamla/tamamlama
  Future<void> toggleReminderCompletion(String reminderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(reminderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final isCompleted = data['isCompleted'] ?? false;

        await _firestore.collection(_collection).doc(reminderId).update({
          'isCompleted': !isCompleted,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Hatırlatıcı durumu güncellenirken hata oluştu: $e');
    }
  }

  // Tek hatırlatıcı getirme
  Future<Reminder?> getReminder(String reminderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(reminderId).get();

      if (doc.exists) {
        return Reminder.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Hatırlatıcı getirilirken hata oluştu: $e');
    }
  }

  // Hatırlatıcı arama
  Stream<List<Reminder>> searchReminders(String userId, String query) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Reminder.fromFirestore(doc.data(), doc.id))
          .where((reminder) =>
              reminder.title.toLowerCase().contains(query.toLowerCase()) ||
              reminder.description
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              reminder.typeDisplayName
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  // Tamamlanmamış hatırlatıcıları getirme
  Stream<List<Reminder>> getIncompleteRemindersForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Pet'e özgü hatırlatıcıları getirme
  Stream<List<Reminder>> getRemindersForPet(String userId, String petId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('petId', isEqualTo: petId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
