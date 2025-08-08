import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reminder_service.dart';
import '../../services/pet_service.dart';
import '../../models/reminder.dart';
import '../../models/pet.dart';

class ReminderAddScreen extends StatefulWidget {
  const ReminderAddScreen({Key? key}) : super(key: key);

  @override
  State<ReminderAddScreen> createState() => _ReminderAddScreenState();
}

class _ReminderAddScreenState extends State<ReminderAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedType = 'other';
  String selectedPriority = 'medium';
  String? selectedPetId;
  List<Pet> availablePets = [];
  bool isLoading = false;
  bool isLoadingPets = true;

  final pastelBackground = const Color(0xFFF3F0FF);
  final pastelBlue = const Color(0xFF7EC8E3);
  final pastelGreen = const Color(0xFFA8E6CF);
  final pastelPink = const Color(0xFFFFB5E8);
  final pastelYellow = const Color(0xFFFFFACD);
  final mainColor = const Color(0xFF6C63FF);
  final textColor = const Color(0xFF333333);

  final List<Map<String, dynamic>> reminderTypes = [
    {
      'value': 'vaccine',
      'label': 'Aşı',
      'icon': Icons.vaccines,
      'color': Colors.red
    },
    {
      'value': 'vet',
      'label': 'Veteriner',
      'icon': Icons.medical_services,
      'color': Colors.blue
    },
    {
      'value': 'medicine',
      'label': 'İlaç',
      'icon': Icons.medication,
      'color': Colors.green
    },
    {
      'value': 'food',
      'label': 'Beslenme',
      'icon': Icons.restaurant,
      'color': Colors.orange
    },
    {
      'value': 'grooming',
      'label': 'Bakım',
      'icon': Icons.content_cut,
      'color': Colors.purple
    },
    {
      'value': 'other',
      'label': 'Diğer',
      'icon': Icons.event_note,
      'color': Colors.grey
    },
  ];

  final List<Map<String, dynamic>> priorities = [
    {'value': 'low', 'label': 'Düşük', 'color': Colors.green},
    {'value': 'medium', 'label': 'Orta', 'color': Colors.orange},
    {'value': 'high', 'label': 'Yüksek', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final petsStream = PetService().getPetsForUser(user.uid);
        petsStream.listen((pets) {
          if (mounted) {
            setState(() {
              availablePets = pets;
              isLoadingPets = false;
            });
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoadingPets = false;
          });
        }
      }
    }
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context).colorScheme.copyWith(primary: mainColor),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context).colorScheme.copyWith(primary: mainColor),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm zorunlu alanları doldurun.'),
          backgroundColor: Colors.red[400],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

      final timeString =
          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

      final reminder = Reminder(
        id: '',
        userId: user.uid,
        petId: selectedPetId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: selectedDate!,
        time: timeString,
        type: selectedType,
        priority: selectedPriority,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ReminderService().addReminder(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hatırlatıcı başarıyla eklendi! 📅'),
            backgroundColor: pastelGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          'Yeni Hatırlatıcı',
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
          padding: const EdgeInsets.all(20),
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
                      backgroundColor: pastelBlue,
                      child: Icon(
                        Icons.add_alert,
                        size: 40,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hatırlatıcı Oluştur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Evcil dostlarınız için önemli\ngünleri unutmayın',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      _buildTextField(
                        controller: titleController,
                        label: 'Başlık *',
                        icon: Icons.title,
                        hint: 'Veteriner randevusu, aşı hatırlatması...',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      _buildTextField(
                        controller: descriptionController,
                        label: 'Açıklama',
                        icon: Icons.description,
                        hint: 'Ek detaylar...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Pet Selection
                      Text(
                        'Evcil Hayvan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: isLoadingPets
                            ? ListTile(
                                leading:
                                    CircularProgressIndicator(color: mainColor),
                                title:
                                    const Text('Evcil hayvanlar yükleniyor...'),
                              )
                            : DropdownButtonFormField<String?>(
                                value: selectedPetId,
                                decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.pets, color: mainColor),
                                  hintText: 'Seçiniz (İsteğe bağlı)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Genel Hatırlatıcı'),
                                  ),
                                  ...availablePets.map((pet) {
                                    return DropdownMenuItem<String?>(
                                      value: pet.id,
                                      child: Text(pet.name),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedPetId = value;
                                  });
                                },
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Date & Time Selection
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tarih *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedDate != null
                                            ? mainColor
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: mainColor),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            selectedDate != null
                                                ? _formatDate(selectedDate!)
                                                : 'Tarih seçin',
                                            style: TextStyle(
                                              color: selectedDate != null
                                                  ? textColor
                                                  : Colors.grey.shade600,
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saat *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _selectTime,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedTime != null
                                            ? mainColor
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: mainColor),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            selectedTime != null
                                                ? selectedTime!.format(context)
                                                : 'Saat seçin',
                                            style: TextStyle(
                                              color: selectedTime != null
                                                  ? textColor
                                                  : Colors.grey.shade600,
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Type Selection
                      Text(
                        'Hatırlatıcı Türü',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: reminderTypes.map((type) {
                          final isSelected = selectedType == type['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = type['value'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? mainColor
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? mainColor
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    type['icon'],
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : type['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type['label'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected ? Colors.white : textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Priority Selection
                      Text(
                        'Öncelik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: priorities.map((priority) {
                          final isSelected =
                              selectedPriority == priority['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPriority = priority['value'];
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? priority['color']
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? priority['color']
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  priority['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected ? Colors.white : textColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                                      Icons.add_alert,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Hatırlatıcı Ekle',
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
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
