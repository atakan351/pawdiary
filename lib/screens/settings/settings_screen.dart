import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final pastelBackground = const Color(0xFFF3F0FF); // Açık lila
    final pastelBlue = const Color(0xFF7EC8E3); // Pastel mavi
    final pastelGreen = const Color(0xFFA8E6CF); // Pastel yeşil
    final pastelPink = const Color(0xFFFFB5E8); // Pastel pembe
    final pastelYellow = const Color(0xFFFFFACD); // Pastel sarı
    final mainColor = const Color(0xFF6C63FF); // Pastel mor
    final textColor = const Color(0xFF333333); // Koyu gri

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ayarlar',
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
              // Profile Card
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
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hesap Ayarları',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Kişiselleştirme & Tercihler',
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

              // Settings Sections
              Text(
                'Görünüm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Theme Setting
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    backgroundColor: pastelYellow,
                    child: Icon(Icons.palette, color: mainColor),
                  ),
                  title: Text(
                    'Tema',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Uygulama görünümünü ayarlayın',
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pastelBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<ThemeMode>(
                      value: themeService.themeMode,
                      underline: const SizedBox(),
                      style: TextStyle(color: textColor, fontSize: 14),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Sistem'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Açık'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Koyu'),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) themeService.setTheme(mode);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App Settings Section
              Text(
                'Uygulama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Notifications
              _buildSettingsItem(
                'Bildirimler',
                'Push bildirimlerini yönetin',
                Icons.notifications,
                pastelGreen,
                () => _showComingSoon(context, 'Bildirim ayarları'),
              ),

              _buildSettingsItem(
                'Veri Yedekleme',
                'Verilerinizi yedekleyin',
                Icons.backup,
                pastelPink,
                () => _showComingSoon(context, 'Veri yedekleme'),
              ),

              _buildSettingsItem(
                'Gizlilik',
                'Gizlilik ve güvenlik ayarları',
                Icons.privacy_tip,
                pastelBlue,
                () => _showComingSoon(context, 'Gizlilik ayarları'),
              ),

              const SizedBox(height: 24),

              // Support Section
              Text(
                'Destek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              _buildSettingsItem(
                'Yardım & Destek',
                'SSS ve iletişim bilgileri',
                Icons.help_outline,
                pastelYellow,
                () => _showComingSoon(context, 'Yardım merkezi'),
              ),

              _buildSettingsItem(
                'Hakkında',
                'Uygulama sürümü ve bilgiler',
                Icons.info_outline,
                pastelGreen,
                () => _showAboutDialog(context),
              ),

              const SizedBox(height: 32),

              // Logout Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final shouldLogout = await _showLogoutDialog(context);
                    if (shouldLogout == true) {
                      await AuthService().signOut();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: const Color(0xFF333333).withOpacity(0.7)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: const Color(0xFF6C63FF).withOpacity(0.5),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature özelliği yakında gelecek! 🚀'),
        backgroundColor: const Color(0xFF7EC8E3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFB5E8),
                child: Icon(Icons.pets, color: const Color(0xFF6C63FF)),
              ),
              const SizedBox(width: 12),
              const Text('Pawdiary Hakkında'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sürüm: 1.0.0'),
              const SizedBox(height: 8),
              const Text('Evcil hayvan bakım ve takip uygulaması'),
              const SizedBox(height: 8),
              Text(
                'Evcil dostlarınızın sağlık, beslenme ve bakım ihtiyaçlarını takip etmenizi sağlar.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red[100],
                child: Icon(Icons.logout, color: Colors.red[400]),
              ),
              const SizedBox(width: 12),
              const Text('Çıkış Yap'),
            ],
          ),
          content: const Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
