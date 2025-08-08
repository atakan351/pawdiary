import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/pet_service.dart';
import '../../models/pet.dart';

class PetRegisterScreen extends StatefulWidget {
  const PetRegisterScreen({Key? key}) : super(key: key);

  @override
  State<PetRegisterScreen> createState() => _PetRegisterScreenState();
}

class _PetRegisterScreenState extends State<PetRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  DateTime? birthDate;
  String gender = 'Erkek';
  final TextEditingController photoUrlController = TextEditingController();
  bool isLoading = false;
  XFile? selectedImage;

  final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
  final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
  final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
  final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
  final mainColor = const Color(0xFF6C63FF); // Pastel mor
  final textColor = const Color(0xFF333333); // Koyu gri

  void _submit() async {
    if (!_formKey.currentState!.validate() || birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm alanları doldurun.'),
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

      String? base64Image;
      if (selectedImage != null) {
        final bytes = await File(selectedImage!.path).readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final pet = Pet(
        id: '',
        name: nameController.text.trim(),
        type: typeController.text.trim(),
        breed: breedController.text.trim(),
        birthDate: birthDate!,
        gender: gender,
        userId: user.uid,
        photoUrl: photoUrlController.text.trim().isNotEmpty
            ? photoUrlController.text.trim()
            : null,
        photoBase64: base64Image,
      );

      await PetService().addPet(pet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evcil dostunuz başarıyla eklendi! 🐾'),
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
          'Yeni Dost Ekle',
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
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        if (picked != null) {
                          setState(() => selectedImage = picked);
                        }
                      },
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: pastelPink,
                        backgroundImage: selectedImage != null
                            ? FileImage(File(selectedImage!.path))
                            : null,
                        child: selectedImage == null
                            ? Icon(Icons.add_a_photo,
                                size: 32, color: mainColor)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Evcil Dostunu Tanıtalım!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Aşağıdaki bilgileri doldurarak yeni\nevcil dostunu ekleyebilirsin',
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
                      _buildTextField(
                        controller: nameController,
                        label: 'İsim',
                        icon: Icons.label,
                        hint: 'Örn: Pamuk, Karabas',
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: typeController,
                        label: 'Tür',
                        icon: Icons.category,
                        hint: 'Örn: Kedi, Köpek, Kuş',
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: breedController,
                        label: 'Cins',
                        icon: Icons.pets,
                        hint: 'Örn: Tekir, Golden Retriever',
                      ),
                      const SizedBox(height: 16),

                      // Birth Date Picker
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.cake, color: mainColor),
                          title: Text(
                            birthDate == null
                                ? 'Doğum Tarihi Seç'
                                : 'Doğum: ${birthDate!.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: birthDate == null
                                  ? Colors.grey.shade600
                                  : textColor,
                              fontWeight: birthDate != null
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
                              initialDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
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
                            if (picked != null)
                              setState(() => birthDate = picked);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gender Dropdown
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: gender,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.wc, color: mainColor),
                            labelText: 'Cinsiyet',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Erkek',
                              child: Text('Erkek ♂'),
                            ),
                            DropdownMenuItem(
                              value: 'Dişi',
                              child: Text('Dişi ♀'),
                            ),
                          ],
                          onChanged: (v) => setState(() => gender = v!),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: photoUrlController,
                        label: 'Fotoğraf URL (İsteğe bağlı)',
                        icon: Icons.link,
                        hint: 'URL eklemek isterseniz',
                        required: false,
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
                                      'Ekleniyor...',
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
                                      'Evcil Dostumu Ekle',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: mainColor),
        labelText: label,
        hintText: hint,
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
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Bu alan zorunludur' : null
          : null,
    );
  }
}
