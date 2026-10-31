import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_notification_service.dart';
import '../theme/app_theme.dart';
import 'tabs/daily_tab.dart';
import 'tabs/leaderboard_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/quizzes_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _tabs = const [
    QuizzesTab(),
    DailyTab(),
    LeaderboardTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Prompt for notification permission cleanly after UI is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService.instance.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: AppTheme.surfaceBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppTheme.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer_rounded),
              activeIcon: Icon(Icons.sports_soccer_rounded, color: AppTheme.primary),
              label: 'Квизы',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              activeIcon: Icon(Icons.task_alt_rounded, color: AppTheme.primary),
              label: 'Дейли',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              activeIcon: Icon(Icons.leaderboard_rounded, color: AppTheme.primary),
              label: 'Рейтинг',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
