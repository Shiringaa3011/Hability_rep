import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

import 'core/design_system/design_system.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/gamification/presentation/pages/achievements_page.dart';
import 'features/gamification/presentation/pages/stats_page.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'injection_container.dart' as di;
import 'core/services/auth_storage.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //добавить навигацию
  });

  await Hive.initFlutter();
  await ThemeModeController.init();
  await di.init();

  runApp(const HabitlyApp());
}

class HabitlyApp extends StatelessWidget {
  const HabitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeModeController.instance,
      builder: (context, _) => MaterialApp(
        title: 'Habitly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeModeController.instance.value,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/home': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as String;
            return _MainShell(userId: args);
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authStorage = di.sl<AuthStorage>();
    final userId = await authStorage.getUserId();
    final isValid = userId != null && userId.isNotEmpty;

    if (isValid) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          final dio = di.sl<Dio>();
          await dio.post('/notifications/fcm-token', data: {
            'user_id': userId,
            'fcm_token': token,
          });
        }
      } catch (_) {}
    }

    setState(() {
      _userId = isValid ? userId : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userId == null) {
      return const LoginPage();
    }

    return _MainShell(userId: _userId!);
  }
}

class _MainShell extends StatefulWidget {
  final String userId;

  _MainShell({required this.userId});

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
        children: [
          HomePage(userId: widget.userId),
          StatsPage(userId: widget.userId),
          AchievementsPage(userId: widget.userId),
          GroupsPage(userId: widget.userId),
          ProfilePage(userId: widget.userId),
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