import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/note_service.dart';
import '../../models/note.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class NoteAddScreen extends StatefulWidget {
  const NoteAddScreen({Key? key}) : super(key: key);

  @override
  State<NoteAddScreen> createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends State<NoteAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? date;
  bool isLoading = false;
  String? _selectedImageBase64;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
  final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
  final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
  final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
  final pastelYellow = const Color(0xFFFFFACD); // Pastel sarı
  final mainColor = const Color(0xFF6C63FF); // Pastel mor
  final textColor = const Color(0xFF333333); // Koyu gri

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final String base64Image = base64Encode(bytes);

        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBase64 = base64Image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fotoğraf seçildi! 📸'),
            backgroundColor: pastelGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf seçilirken hata: $e'),
          backgroundColor: Colors.red[400],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final String base64Image = base64Encode(bytes);

        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBase64 = base64Image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fotoğraf çekildi! 📸'),
            backgroundColor: pastelGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf çekilirken hata: $e'),
          backgroundColor: Colors.red[400],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageBase64 = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fotoğraf kaldırıldı'),
        backgroundColor: Colors.orange[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Fotoğraf Ekle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: pastelBlue.withOpacity(0.3),
                  child: Icon(Icons.camera_alt, color: mainColor),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Yeni fotoğraf çek'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: pastelGreen.withOpacity(0.3),
                  child: Icon(Icons.photo_library, color: mainColor),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Mevcut fotoğraflardan seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_selectedImageFile != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: pastelPink.withOpacity(0.3),
                    child: Icon(Icons.delete, color: Colors.red[400]),
                  ),
                  title: const Text('Fotoğrafı Kaldır'),
                  subtitle: const Text('Seçili fotoğrafı sil'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm zorunlu alanları doldurun.'),
          backgroundColor: Colors.red[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final note = Note(
        id: '',
        userId: user.uid,
        petId: null,
        date: date!,
        description: descriptionController.text.trim(),
        photoBase64: _selectedImageBase64,
      );

      await NoteService().addNote(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anınız başarıyla kaydedildi! 📝'),
            backgroundColor: pastelGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Yeni Anı Kaydet',
          style: TextStyle(
            color: mainColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: mainColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
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
                      radius: 40,
                      backgroundColor: pastelYellow,
                      child: Icon(
                        Icons.auto_stories,
                        size: 40,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Güzel Bir Anı Paylaşalım!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Evcil dostunuzla yaşadığınız özel\nanları burada kaydedin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Photo Section
                      Container(
                        width: double.infinity,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedImageFile != null
                                ? mainColor
                                : Colors.grey.shade300,
                            width: _selectedImageFile != null ? 2 : 1,
                          ),
                        ),
                        child: _selectedImageFile != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _selectedImageFile!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _showImagePickerDialog,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: _showImagePickerDialog,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          mainColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        size: 30,
                                        color: mainColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Fotoğraf Ekle',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: mainColor,
                                      ),
                                    ),
                                    Text(
                                      'Anınızı fotoğrafla ölümsüzleştirin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      // Description Field
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.edit_note, color: mainColor),
                          ),
                          labelText: 'Anınızı Anlatın *',
                          hintText:
                              'Bu güzel anı hakkında neler söylemek istersiniz?',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: mainColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bu alan zorunludur'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                date != null ? mainColor : Colors.grey.shade300,
                            width: date != null ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.event, color: mainColor),
                          title: Text(
                            date == null
                                ? 'Anının Tarihini Seçin *'
                                : 'Tarih: ${_formatDate(date!)}',
                            style: TextStyle(
                              color: date == null
                                  ? Colors.grey.shade600
                                  : textColor,
                              fontWeight: date != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Icon(
                            Icons.calendar_today,
                            color: mainColor,
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(
                                      context,
                                    ).colorScheme.copyWith(primary: mainColor),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) setState(() => date = picked);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: mainColor.withOpacity(0.3),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Kaydediliyor...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Anımı Kaydet',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
