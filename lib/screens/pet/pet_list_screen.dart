import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/pet_service.dart';
import '../../models/pet.dart';
import 'pet_register_screen.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
    final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
    final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
    final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
    final mainColor = const Color(0xFF6C63FF); // Pastel mor
    final textColor = const Color(0xFF333333); // Koyu gri

    if (user == null) {
      return Scaffold(
        backgroundColor: pastelBackground,
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: pastelPink,
                    child: Icon(Icons.warning, size: 40, color: mainColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Giriş yapmalısınız.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: Text(
            'Evcil Hayvanlarım',
            style: TextStyle(
              color: mainColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: mainColor),
      ),
      body: StreamBuilder<List<Pet>>(
        stream: PetService().getPetsForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: mainColor),
                  const SizedBox(height: 16),
                  Text(
                    'Evcil dostlarınız yükleniyor...',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
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
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: pastelBlue,
                          child: Icon(Icons.pets, size: 48, color: mainColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz evcil dostunuz yok!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk evcil dostunuzu eklemek için\naşağıdaki butona tıklayın',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final pets = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final colors = [pastelBlue, pastelGreen, pastelPink];
                final cardColor = colors[index % colors.length];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                        height: 120,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Builder(builder: (context) {
                            Widget fallback = CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.pets,
                                size: 40,
                                color: mainColor,
                              ),
                            );

                            if (pet.photoUrl != null &&
                                pet.photoUrl!.isNotEmpty) {
                              return ClipOval(
                                child: Image.network(
                                  pet.photoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      fallback,
                                ),
                              );
                            }

                            if (pet.photoBase64 != null &&
                                pet.photoBase64!.isNotEmpty) {
                              try {
                                final bytes = base64Decode(pet.photoBase64!);
                                return ClipOval(
                                  child: Image.memory(
                                    bytes,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } catch (_) {
                                return fallback;
                              }
                            }

                            return fallback;
                          }),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pet.type} - ${pet.breed}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      pet.age,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      pet.ageCategory,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  if (pet.isBirthdayToday)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.pink.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '🎂 Doğum günü!',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PetRegisterScreen(),
              ),
            );
          },
          backgroundColor: mainColor,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Yeni Dost',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
