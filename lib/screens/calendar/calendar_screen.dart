import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reminder_service.dart';
import '../../models/reminder.dart';
import 'reminder_add_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final pastelBackground = const Color(0xFFF3F0FF);
    final pastelBlue = const Color(0xFF7EC8E3);
    final pastelPink = const Color(0xFFFFB5E8);
    final mainColor = const Color(0xFF6C63FF);
    final textColor = const Color(0xFF333333);

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
          'Takvim & Hatırlatıcılar',
          style: TextStyle(
            color: mainColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: mainColor),
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: ReminderService().getRemindersForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: mainColor),
                  const SizedBox(height: 16),
                  Text(
                    'Hatırlatıcılarınız yükleniyor...',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final allReminders = snapshot.data ?? [];

          // Bugünkü hatırlatıcıları filtrele
          final todayReminders = allReminders.where((reminder) {
            final reminderDate = reminder.date;
            final now = DateTime.now();
            return reminderDate.year == now.year &&
                reminderDate.month == now.month &&
                reminderDate.day == now.day;
          }).toList();

          // Yaklaşan hatırlatıcıları filtrele (gelecek 7 gün)
          final upcomingReminders = allReminders.where((reminder) {
            final reminderDate = reminder.date;
            final now = DateTime.now();
            final difference = reminderDate.difference(now).inDays;
            return difference >= 0 && difference <= 7;
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Summary Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [mainColor, mainColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Icon(
                                Icons.today,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bugün',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(DateTime.now()),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildSummaryItem(
                              'Bugün',
                              todayReminders.length.toString(),
                              Icons.event_note,
                            ),
                            const SizedBox(width: 20),
                            _buildSummaryItem(
                              'Bu Hafta',
                              upcomingReminders.length.toString(),
                              Icons.date_range,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Today's Reminders
                  if (todayReminders.isNotEmpty) ...[
                    Text(
                      'Bugünkü Hatırlatıcılar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...todayReminders.map(
                      (reminder) => _buildReminderCard(
                          reminder, true, mainColor, textColor),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Upcoming Reminders
                  Text(
                    'Yaklaşan Hatırlatıcılar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (upcomingReminders.isEmpty)
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
                            radius: 40,
                            backgroundColor: pastelBlue,
                            child: Icon(
                              Icons.event_available,
                              size: 40,
                              color: mainColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Yaklaşan hatırlatıcınız yok!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Evcil dostlarınız için hatırlatıcı ekleyebilirsiniz',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...upcomingReminders.map(
                      (reminder) => _buildReminderCard(
                          reminder, false, mainColor, textColor),
                    ),

                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
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
                builder: (context) => const ReminderAddScreen(),
              ),
            );
          },
          backgroundColor: mainColor,
          elevation: 0,
          icon: const Icon(Icons.add_alert, color: Colors.white),
          label: const Text(
            'Hatırlatıcı Ekle',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
      Reminder reminder, bool isToday, Color mainColor, Color textColor) {
    // Type'a göre icon ve color seç
    Map<String, dynamic> typeInfo = _getTypeInfo(reminder.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: mainColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: (typeInfo['color'] as Color).withOpacity(0.2),
          child: Icon(
            typeInfo['icon'] as IconData,
            color: typeInfo['color'] as Color,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description.isNotEmpty) ...[
              Text(reminder.description),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDateShort(reminder.date)} - ${reminder.time}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        _getPriorityColor(reminder.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reminder.priorityDisplayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(reminder.priority),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BUGÜN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (reminder.isCompleted) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
            ],
          ],
        ),
        onTap: () {
          _showReminderDetails(reminder);
        },
      ),
    );
  }

  Map<String, dynamic> _getTypeInfo(String type) {
    switch (type) {
      case 'vaccine':
        return {'icon': Icons.vaccines, 'color': Colors.red};
      case 'vet':
        return {'icon': Icons.medical_services, 'color': Colors.blue};
      case 'medicine':
        return {'icon': Icons.medication, 'color': Colors.green};
      case 'food':
        return {'icon': Icons.restaurant, 'color': Colors.orange};
      case 'grooming':
        return {'icon': Icons.content_cut, 'color': Colors.purple};
      default:
        return {'icon': Icons.event_note, 'color': Colors.grey};
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _showReminderDetails(Reminder reminder) {
    // Hatırlatıcı detay gösterimi - gelecekte implement edilecek
    print('Show reminder details for: ${reminder.title}');
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
    final days = [
      'Pazar',
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
    ];
    return '${date.day} ${months[date.month - 1]}, ${days[date.weekday % 7]}';
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Yarın';
    } else if (difference < 7) {
      return '${difference + 1} gün sonra';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
