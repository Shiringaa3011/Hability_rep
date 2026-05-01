import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/design_system/design_system.dart';
import 'features/gamification/presentation/pages/achievements_page.dart';
import 'features/gamification/presentation/pages/stats_page.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await di.init();

  runApp(const HabitlyApp());
}

class HabitlyApp extends StatelessWidget {
  const HabitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  static const String mockUserId = '00000000-0000-0000-0000-000000000001';

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  static const List<DSBottomNavItem> _navItems = [
    DSBottomNavItem(
      icon: DSIcons.habits,
      activeIcon: DSIcons.habitsActive,
      label: 'Привычки',
    ),
    DSBottomNavItem(
      icon: DSIcons.stats,
      activeIcon: DSIcons.statsActive,
      label: 'Статистика',
    ),
    DSBottomNavItem(
      icon: DSIcons.achievements,
      activeIcon: DSIcons.achievementsActive,
      label: 'Награды',
    ),
    DSBottomNavItem(
      icon: DSIcons.groups,
      activeIcon: DSIcons.groupsActive,
      label: 'Группы',
    ),
    DSBottomNavItem(
      icon: DSIcons.profile,
      activeIcon: DSIcons.profileActive,
      label: 'Профиль',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(userId: _MainShell.mockUserId),
          StatsPage(userId: _MainShell.mockUserId),
          AchievementsPage(userId: _MainShell.mockUserId),
          GroupsPage(userId: _MainShell.mockUserId),
          ProfilePage(userId: _MainShell.mockUserId),
        ],
      ),
      bottomNavigationBar: DSBottomNav(
        items: _navItems,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
