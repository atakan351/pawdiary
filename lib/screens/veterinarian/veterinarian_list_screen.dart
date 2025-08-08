import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/veterinarian_service.dart';
import '../../models/veterinarian.dart';
import 'veterinarian_add_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class VeterinarianListScreen extends StatelessWidget {
  const VeterinarianListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
    final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
    final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
    final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
    final pastelYellow = const Color(0xFFFFFACD); // Pastel sarı
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
        title: Text(
          'Veterinerlerim',
          style: TextStyle(
            color: mainColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: mainColor),
      ),
      body: StreamBuilder<List<Veterinarian>>(
        stream: VeterinarianService().getVeterinariansForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: mainColor),
                  const SizedBox(height: 16),
                  Text(
                    'Veterinerleriniz yükleniyor...',
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
                          backgroundColor: pastelGreen,
                          child: Icon(
                            Icons.medical_services,
                            size: 48,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz veteriner eklemediniz!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Evcil dostlarınızın sağlığı için\nveteriner bilgilerini kaydedin',
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

          final veterinarians = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: veterinarians.length,
            itemBuilder: (context, index) {
              final vet = veterinarians[index];
              final colors = [
                pastelBlue,
                pastelGreen,
                pastelPink,
                pastelYellow
              ];
              final cardColor = colors[index % colors.length];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.medical_services,
                              size: 30,
                              color: mainColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vet.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  vet.clinicName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'call') {
                                await _makePhoneCall(vet.phone);
                              } else if (value == 'email') {
                                await _sendEmail(vet.email);
                              } else if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VeterinarianAddScreen(
                                        veterinarian: vet),
                                  ),
                                );
                              } else if (value == 'delete') {
                                await _showDeleteDialog(context, vet);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'call',
                                child: Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.green),
                                    const SizedBox(width: 8),
                                    const Text('Ara'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'email',
                                child: Row(
                                  children: [
                                    Icon(Icons.email, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    const Text('E-posta Gönder'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    const Text('Düzenle'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    const SizedBox(width: 8),
                                    const Text('Sil'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vet.specialization.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                vet.specialization,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (vet.phone.isNotEmpty)
                            _buildInfoRow(Icons.phone, vet.phone, Colors.green),
                          if (vet.email.isNotEmpty)
                            _buildInfoRow(Icons.email, vet.email, Colors.blue),
                          if (vet.address.isNotEmpty)
                            _buildInfoRow(
                                Icons.location_on, vet.address, Colors.red),
                          if (vet.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                vet.notes,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
                builder: (context) => const VeterinarianAddScreen(),
              ),
            );
          },
          backgroundColor: mainColor,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Yeni Veteriner',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri url = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, Veterinarian vet) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Veteriner Sil'),
        content: Text(
            '${vet.name} adlı veterineri silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await VeterinarianService().deleteVeterinarian(vet.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veteriner başarıyla silindi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
