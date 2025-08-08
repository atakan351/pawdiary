import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/pet_service.dart';
import '../services/note_service.dart';
import '../services/veterinarian_service.dart';
import '../models/pet.dart';
import '../models/note.dart';
import '../models/veterinarian.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
    final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
    final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
    final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
    final pastelYellow = const Color(0xFFFFFACD); // Pastel sarı
    final mainColor = const Color(0xFF6C63FF); // Pastel mor (başlık)
    final textColor = const Color(0xFF333333); // Koyu gri

    return Scaffold(
      backgroundColor: pastelBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pet-friendly illustration
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: pastelBlue,
                      child: Icon(Icons.pets, size: 64, color: mainColor),
                    ),
                  ),
                  Text(
                    'Hoş geldiniz!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pawdiary ile evcil dostlarını kolayca yönet!',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // İstatistik Kartları
                  if (user != null)
                    _buildStatsRow(context, user.uid, mainColor, pastelBlue,
                        pastelGreen, pastelPink, textColor)
                  else
                    _buildEmptyStatsRow(context, mainColor, pastelBlue,
                        pastelGreen, pastelPink, textColor),

                  const SizedBox(height: 24),

                  // Hızlı Erişim Bilgileri
                  _buildQuickInfoSection(
                      context, mainColor, pastelYellow, textColor),

                  const SizedBox(height: 32),

                  // Navigasyon İpucu
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: mainColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: mainColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tüm özelliklere alttaki menüden erişebilirsiniz',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  TextButton.icon(
                    onPressed: () async {
                      await AuthService().signOut();
                    },
                    icon: Icon(Icons.logout, color: Colors.red[400]),
                    label: Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, String userId, Color mainColor,
      Color pastelBlue, Color pastelGreen, Color pastelPink, Color textColor) {
    return StreamBuilder<List<Pet>>(
      stream: PetService().getPetsForUser(userId),
      builder: (context, petSnapshot) {
        return StreamBuilder<List<Note>>(
          stream: NoteService().getNotesForUser(userId),
          builder: (context, noteSnapshot) {
            return StreamBuilder<List<Veterinarian>>(
              stream: VeterinarianService().getVeterinariansForUser(userId),
              builder: (context, vetSnapshot) {
                final petCount = petSnapshot.data?.length ?? 0;
                final noteCount = noteSnapshot.data?.length ?? 0;
                final vetCount = vetSnapshot.data?.length ?? 0;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '🐾',
                        'Dostlarım',
                        petCount.toString(),
                        pastelBlue,
                        textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '📝',
                        'Anılarım',
                        noteCount.toString(),
                        pastelGreen,
                        textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '🏥',
                        'Veteriner',
                        vetCount.toString(),
                        pastelPink,
                        textColor,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyStatsRow(BuildContext context, Color mainColor,
      Color pastelBlue, Color pastelGreen, Color pastelPink, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '🐾',
            'Dostlarım',
            '0',
            pastelBlue,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '📝',
            'Anılarım',
            '0',
            pastelGreen,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '🏥',
            'Veteriner',
            '0',
            pastelPink,
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String title, String count, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoSection(BuildContext context, Color mainColor,
      Color pastelYellow, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: pastelYellow,
                child: Icon(Icons.lightbulb, color: mainColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Günün İpucu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Evcil dostlarınızın sağlığı için düzenli veteriner kontrolü yaptırmayı unutmayın! 🏥',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: mainColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yaklaşan randevularınız için takvim sekmesini kontrol edin',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
