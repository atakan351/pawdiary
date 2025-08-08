import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/veterinarian_service.dart';
import '../../models/veterinarian.dart';

class VeterinarianAddScreen extends StatefulWidget {
  final Veterinarian? veterinarian;

  const VeterinarianAddScreen({Key? key, this.veterinarian}) : super(key: key);

  @override
  State<VeterinarianAddScreen> createState() => _VeterinarianAddScreenState();
}

class _VeterinarianAddScreenState extends State<VeterinarianAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isLoading = false;
  bool isEditing = false;

  final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
  final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
  final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
  final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
  final pastelYellow = const Color(0xFFFFFACD); // Pastel sarı
  final mainColor = const Color(0xFF6C63FF); // Pastel mor
  final textColor = const Color(0xFF333333); // Koyu gri

  final List<String> specializations = [
    'Genel Veteriner Hekim',
    'Küçük Hayvan Uzmanı',
    'Büyük Hayvan Uzmanı',
    'Egzotik Hayvan Uzmanı',
    'Dermatolog',
    'Kardiyolog',
    'Oftalmolog',
    'Ortopedist',
    'Diş Hekimi',
    'Acil Tıp Uzmanı',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.veterinarian != null) {
      isEditing = true;
      _fillFormWithExistingData();
    }
  }

  void _fillFormWithExistingData() {
    final vet = widget.veterinarian!;
    nameController.text = vet.name;
    clinicController.text = vet.clinicName;
    phoneController.text = vet.phone;
    emailController.text = vet.email;
    addressController.text = vet.address;
    specializationController.text = vet.specialization;
    notesController.text = vet.notes;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (isEditing) {
        // Güncelleme işlemi
        final updatedVet = widget.veterinarian!.copyWith(
          name: nameController.text.trim(),
          clinicName: clinicController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          address: addressController.text.trim(),
          specialization: specializationController.text.trim(),
          notes: notesController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await VeterinarianService().updateVeterinarian(updatedVet);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Veteriner bilgileri güncellendi! 👨‍⚕️'),
              backgroundColor: pastelGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Yeni ekleme işlemi
        final veterinarian = Veterinarian(
          id: '',
          userId: user.uid,
          name: nameController.text.trim(),
          clinicName: clinicController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          address: addressController.text.trim(),
          specialization: specializationController.text.trim(),
          notes: notesController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await VeterinarianService().addVeterinarian(veterinarian);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Veteriner başarıyla eklendi! 👨‍⚕️'),
              backgroundColor: pastelGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          isEditing ? 'Veteriner Düzenle' : 'Yeni Veteriner Ekle',
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
                      backgroundColor: pastelGreen,
                      child: Icon(
                        Icons.medical_services,
                        size: 40,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEditing
                          ? 'Veteriner Bilgilerini Güncelle'
                          : 'Veteriner Bilgilerini Kaydet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Evcil dostlarınızın sağlığı için\nveteriner bilgilerini düzenli tutun',
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
                        label: 'Veteriner Adı',
                        icon: Icons.person,
                        hint: 'Dr. Mehmet Yılmaz',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: clinicController,
                        label: 'Klinik/Hastane Adı',
                        icon: Icons.local_hospital,
                        hint: 'Dostlar Veteriner Kliniği',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: phoneController,
                        label: 'Telefon',
                        icon: Icons.phone,
                        hint: '+90 555 123 45 67',
                        keyboardType: TextInputType.phone,
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: emailController,
                        label: 'E-posta',
                        icon: Icons.email,
                        hint: 'info@veterinerklinik.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: addressController,
                        label: 'Adres',
                        icon: Icons.location_on,
                        hint: 'Merkez Mah. Veteriner Cad. No:123',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Specialization Dropdown
                      DropdownButtonFormField<String>(
                        value: specializationController.text.isNotEmpty
                            ? specializationController.text
                            : null,
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.medical_information, color: mainColor),
                          labelText: 'Uzmanlık Alanı',
                          hintText: 'Seçiniz',
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
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: specializations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            specializationController.text = newValue ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: notesController,
                        label: 'Notlar (İsteğe bağlı)',
                        icon: Icons.note,
                        hint: 'Ek bilgiler, özel notlar...',
                        maxLines: 3,
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
                                    Text(
                                      isEditing
                                          ? 'Güncelleniyor...'
                                          : 'Kaydediliyor...',
                                      style: const TextStyle(
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
                                      Icons.medical_services,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEditing
                                          ? 'Veteriner Güncelle'
                                          : 'Veteriner Ekle',
                                      style: const TextStyle(
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
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  @override
  void dispose() {
    nameController.dispose();
    clinicController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    specializationController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
