import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/gamification/presentation/bloc/achievements/achievements_bloc.dart';
import 'features/gamification/presentation/bloc/level/level_bloc.dart';
import 'features/gamification/presentation/bloc/stats/stats_bloc.dart';
import 'features/gamification/presentation/pages/achievements_page.dart';
import 'features/gamification/presentation/pages/level_page.dart';
import 'features/gamification/presentation/pages/stats_page.dart';
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
      title: 'Habitly - Геймификация',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const String mockUserId = '00000000-0000-0000-0000-000000000001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BlocProvider(
            create: (_) => di.sl<StatsBloc>(),
            child: const StatsPage(userId: mockUserId),
          ),
          BlocProvider(
            create: (_) => di.sl<LevelBloc>(),
            child: const LevelPage(userId: mockUserId),
          ),
          BlocProvider(
            create: (_) => di.sl<AchievementsBloc>(),
            child: const AchievementsPage(userId: mockUserId),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Уровень',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars),
            label: 'Достижения',
          ),
        ],
      ),
    );
  }
}
