import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/design_system/design_system.dart';
import 'features/gamification/presentation/pages/stats_hub_page.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
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

//нижняя панель
class _MainShell extends StatefulWidget {
  const _MainShell();

  //mock
  static const String mockUserId = '00000000-0000-0000-0000-000000000001';

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomePage(userId: _MainShell.mockUserId),
          const GroupsPage(userId: _MainShell.mockUserId),
          const StatsHubPage(userId: _MainShell.mockUserId),
          const SettingsPage(userId: _MainShell.mockUserId),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Группы',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
