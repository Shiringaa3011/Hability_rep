import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_history_item.dart';
import '../../domain/entities/notification_settings_snapshot.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    Connectivity? connectivity,
    FirebaseMessaging? firebaseMessaging,
  })  : _connectivity = connectivity ?? Connectivity(),
        _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  // MOCK: in-memory хранилище
  final List<NotificationHistoryItem> _items = [
    NotificationHistoryItem(
      id: 'n1',
      title: 'Напоминание: вода',
      body: 'Не забудьте отметить привычку «Стакан воды».',
      receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
      read: false,
    ),
    NotificationHistoryItem(
      id: 'n2',
      title: 'Новый участник в группе',
      body: 'Пётр присоединился к группе «Друзья».',
      receivedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      read: true,
    ),
    NotificationHistoryItem(
      id: 'n3',
      title: 'Серия 5 дней',
      body: 'Вы поддерживаете серию по привычке «Медитация». Так держать!',
      receivedAt: DateTime.now().subtract(const Duration(days: 2)),
      read: false,
    ),
  ];

  NotificationSettingsSnapshot _settings = const NotificationSettingsSnapshot(
    allowNotifications: true,
    soundEnabled: true,
    vibrationEnabled: true,
  );

  final Connectivity _connectivity;
  final FirebaseMessaging _firebaseMessaging;

  final List<_QueuedNotification> _offlineQueue = <_QueuedNotification>[];
  final Map<String, DateTime> _lastSentByDedupKey = <String, DateTime>{};

  bool _initialized = false;
  bool _isOnline = true;

  @override
  Future<void> bootstrapNotificationPipeline(String userId) async {
    if (_initialized) return;
    _initialized = true;

    await _initFirebaseMessaging();
    await _initConnectivityWatcher();
    _seedMockTriggers(userId);
    await _flushQueue();
  }

  @override
  Future<List<NotificationHistoryItem>> getHistory(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _trimHistoryForLast30Days();
    return List<NotificationHistoryItem>.from(_items)
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  @override
  Future<void> markRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final i = _items.indexWhere((e) => e.id == notificationId);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(read: true);
  }

  @override
  Future<NotificationSettingsSnapshot> getSettings(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return _settings;
  }

  @override
  Future<void> saveSettings(
    String userId,
    NotificationSettingsSnapshot settings,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _settings = settings;
    if (_settings.allowNotifications) {
      await _flushQueue();
    }
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      await Firebase.initializeApp();
      await _firebaseMessaging.requestPermission();

      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM token: $token');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? 'Firebase уведомление';
        final body = message.notification?.body ?? 'Новое событие в Habitly';
        _appendHistory(title: title, body: body);
      });
    } catch (e) {
      // MOCK: для локальной разработки допускаем отсутствие firebase options.
      debugPrint('Firebase init skipped: $e');
    }
  }

  Future<void> _initConnectivityWatcher() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);

    _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);
      if (!wasOnline && _isOnline) {
        Future<void>.delayed(const Duration(seconds: 1), _flushQueue);
      }
    });
  }

  void _seedMockTriggers(String userId) {
    // MOCK: вместо чтения триггеров используем фиктивные события
    final now = DateTime.now();
    final eventTime = now.add(const Duration(hours: 1));

    _scheduleReminder(
      userId: userId,
      habitId: 'habit_water_01',
      habitTitle: 'Стакан воды',
      plannedAt: eventTime,
    );

    _queueOrSend(
      _QueuedNotification(
        id: 'achievement_${now.microsecondsSinceEpoch}',
        dedupKey: 'achievement:level-up',
        title: 'Новый уровень',
        body: 'Вы достигли 7 уровня. Продолжайте в том же духе!',
        createdAt: now,
        sendBefore: now.add(const Duration(days: 7)),
      ),
    );
  }

  void _scheduleReminder({
    required String userId,
    required String habitId,
    required String habitTitle,
    DateTime? plannedAt,
  }) {
    final now = DateTime.now();
    final localPlannedAt = plannedAt ?? DateTime(now.year, now.month, now.day, 12);
    final sendAt = localPlannedAt.subtract(const Duration(minutes: 30));
    final fallbackDeadline = plannedAt == null
        ? DateTime(now.year, now.month, now.day, 23, 59, 59)
        : localPlannedAt;

    _queueOrSend(
      _QueuedNotification(
        id: 'reminder_${habitId}_${now.microsecondsSinceEpoch}',
        dedupKey: 'reminder:$userId:$habitId:${localPlannedAt.toIso8601String()}',
        title: 'Напоминание: $habitTitle',
        body: 'Через 30 минут запланировано выполнение привычки.',
        createdAt: now,
        notBefore: sendAt,
        sendBefore: fallbackDeadline,
      ),
    );
  }

  Future<void> _queueOrSend(_QueuedNotification item) async {
    if (!_settings.allowNotifications) return;

    final now = DateTime.now();
    if (item.notBefore != null && now.isBefore(item.notBefore!)) {
      _offlineQueue.add(item);
      return;
    }

    if (!_isOnline) {
      _offlineQueue.add(item);
      return;
    }

    await _sendWithDedup(item);
  }

  Future<void> _flushQueue() async {
    if (!_settings.allowNotifications || !_isOnline) return;
    if (_offlineQueue.isEmpty) return;

    final now = DateTime.now();
    final pending = List<_QueuedNotification>.from(_offlineQueue);
    _offlineQueue.clear();

    for (final item in pending) {
      if (now.isAfter(item.sendBefore)) {
        continue;
      }
      if (item.notBefore != null && now.isBefore(item.notBefore!)) {
        _offlineQueue.add(item);
        continue;
      }
      await _sendWithDedup(item);
    }
  }

  Future<void> _sendWithDedup(_QueuedNotification item) async {
    final now = DateTime.now();
    final lastSent = _lastSentByDedupKey[item.dedupKey];
    if (lastSent != null && now.difference(lastSent) < const Duration(hours: 24)) {
      return;
    }

    try {
      // MOCK-режим
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _lastSentByDedupKey[item.dedupKey] = now;
      _appendHistory(title: item.title, body: item.body);
    } catch (e) {
      debugPrint('Failed to send notification: $e');
      if (now.isBefore(item.sendBefore)) {
        _offlineQueue.add(item);
      }
    }
  }

  void _appendHistory({
    required String title,
    required String body,
  }) {
    _items.add(
      NotificationHistoryItem(
        id: 'n_${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        read: false,
      ),
    );
    _trimHistoryForLast30Days();
  }

  void _trimHistoryForLast30Days() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _items.removeWhere((item) => item.receivedAt.isBefore(cutoff));
  }
}

class _QueuedNotification {
  const _QueuedNotification({
    required this.id,
    required this.dedupKey,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.sendBefore,
    this.notBefore,
  });

  final String id;
  final String dedupKey;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime sendBefore;
  final DateTime? notBefore;
}
