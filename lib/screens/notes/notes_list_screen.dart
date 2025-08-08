import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/note_service.dart';
import '../../models/note.dart';
import 'note_add_screen.dart';
import 'note_detail_screen.dart';
import 'dart:convert';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({Key? key}) : super(key: key);

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
          'Notlar & Anılar',
          style: TextStyle(
            color: mainColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: mainColor),
      ),
      body: StreamBuilder<List<Note>>(
        stream: NoteService().getNotesForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: mainColor),
                  const SizedBox(height: 16),
                  Text(
                    'Anılarınız yükleniyor...',
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
                          backgroundColor: pastelYellow,
                          child: Icon(
                            Icons.auto_stories,
                            size: 48,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz anınız yok!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Evcil dostlarınızla yaşadığınız\ngüzel anıları kaydetmeye başlayın',
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

          final notes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final colors = [
                pastelBlue,
                pastelGreen,
                pastelPink,
                pastelYellow,
              ];
              final cardColor = colors[index % colors.length];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailScreen(note: note),
                    ),
                  );
                },
                child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with photo or icon
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: note.photoBase64 != null
                                  ? ClipOval(
                                      child: _buildImageFromBase64(
                                        note.photoBase64!,
                                        48,
                                        48,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.auto_stories,
                                        color: mainColor,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Anı',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        if (note.photoBase64 != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.photo_camera,
                                                  size: 10,
                                                  color: mainColor,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  'Foto',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: mainColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      _formatDate(note.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: textColor,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (note.description.length > 100 ||
                                note.photoBase64 != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Detayları görmek için tıklayın',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: mainColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color: mainColor,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
              MaterialPageRoute(builder: (context) => const NoteAddScreen()),
            );
          },
          backgroundColor: mainColor,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Yeni Anı',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildImageFromBase64(
      String base64String, double width, double height) {
    try {
      return Image.memory(
        base64Decode(base64String),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(width / 2),
          ),
          child: Icon(
            Icons.broken_image,
            color: Colors.grey.shade400,
            size: width * 0.5,
          ),
        ),
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(width / 2),
        ),
        child: Icon(
          Icons.error,
          color: Colors.red.shade400,
          size: width * 0.5,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
