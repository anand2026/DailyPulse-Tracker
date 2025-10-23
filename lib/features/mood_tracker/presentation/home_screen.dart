import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'mood_log_screen.dart';
import 'mood_history_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MoodLogScreen(),
    MoodHistoryScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.solidHeart),
            label: 'Log Mood',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.calendarDays),
            label: 'History',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.chartLine),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
