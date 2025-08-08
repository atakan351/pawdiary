import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/notes/notes_list_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/pet/pet_list_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/veterinarian/veterinarian_list_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final pastelBlue = const Color(0xFF7EC8E3);
  final pastelGreen = const Color(0xFFA8E6CF);
  final pastelPink = const Color(0xFFFFB5E8);
  final pastelYellow = const Color(0xFFFFFACD);
  final mainColor = const Color(0xFF6C63FF);

  final List<Widget> _screens = [
    const HomeScreen(),
    const PetListScreen(),
    const VeterinarianListScreen(),
    const CalendarScreen(),
    const NotesListScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      activeIcon: Icon(Icons.home),
      label: 'Ana Sayfa',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.pets),
      activeIcon: Icon(Icons.pets),
      label: 'Dostlarım',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.medical_services),
      activeIcon: Icon(Icons.medical_services),
      label: 'Veteriner',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      activeIcon: Icon(Icons.calendar_month),
      label: 'Takvim',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.auto_stories),
      activeIcon: Icon(Icons.auto_stories),
      label: 'Anılar',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      activeIcon: Icon(Icons.analytics),
      label: 'İstatistik',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      activeIcon: Icon(Icons.settings),
      label: 'Ayarlar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            elevation: 0,
            items: _navItems,
          ),
        ),
      ),
    );
  }
}
