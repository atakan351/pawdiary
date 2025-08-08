import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
    final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
    final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
    final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
    final mainColor = const Color(0xFF6C63FF); // Pastel mor
    final textColor = const Color(0xFF333333); // Koyu gri

    // Örnek veri
    final stats = [
      {
        'petName': 'Pamuk',
        'petType': 'Kedi',
        'age': '2 yaş',
        'lastVaccine': '2024-06-01',
        'nextVaccine': '2025-06-01',
        'careSuggestion': 'Tüy bakımı zamanı geldi!',
        'health': 'Mükemmel',
        'weight': '4.2 kg',
      },
      {
        'petName': 'Karabas',
        'petType': 'Köpek',
        'age': '5 yaş',
        'lastVaccine': '2024-04-15',
        'nextVaccine': '2025-04-15',
        'careSuggestion': 'Tırnak kesimi zamanı.',
        'health': 'İyi',
        'weight': '18.7 kg',
      },
    ];

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'İstatistikler & Sağlık',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.analytics,
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
                            'Sağlık & Bakım Takibi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Evcil Dostlarınızın Durumu',
                            style: TextStyle(
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
              ),

              // Pet Stats Cards
              ...stats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                final colors = [pastelBlue, pastelGreen, pastelPink];
                final cardColor = colors[index % colors.length];
                final nextVaccineDate = DateTime.parse(
                  stat['nextVaccine'] as String,
                );
                final daysLeft = nextVaccineDate
                    .difference(DateTime.now())
                    .inDays;
                final isUrgent = daysLeft <= 30;

                return _buildPetCard(
                  stat,
                  cardColor,
                  textColor,
                  mainColor,
                  isUrgent,
                  daysLeft,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(
    Map<String, dynamic> stat,
    Color cardColor,
    Color textColor,
    Color mainColor,
    bool isUrgent,
    int daysLeft,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isUrgent ? Border.all(color: Colors.red, width: 2) : null,
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
          // Pet Header
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
                  child: Icon(Icons.pets, size: 30, color: mainColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat['petName'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '${stat['petType']} • ${stat['age']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACİL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Pet Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Health & Weight
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.favorite, color: Colors.green, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              stat['health'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'Sağlık',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.monitor_weight,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat['weight'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'Ağırlık',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vaccine Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.vaccines,
                            color: isUrgent ? Colors.red : mainColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Aşı Takibi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isUrgent ? Colors.red : mainColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$daysLeft gün',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Son Aşı: ${stat['lastVaccine']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Sonraki Aşı: ${stat['nextVaccine']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Care Suggestion
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: mainColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stat['careSuggestion'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
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
