import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/group_entity.dart';

abstract class GroupLocalDataSource {
  List<GroupEntity>? getCachedGroups(String userId);
  Future<void> cacheGroups(String userId, List<GroupEntity> groups);
  Future<void> invalidateGroups(String userId);
}

class GroupLocalDataSourceImpl implements GroupLocalDataSource {
  static const String _boxName = 'groups_cache';
  late Box<String> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox<String>(_boxName);
    _initialized = true;
  }

  @override
  List<GroupEntity>? getCachedGroups(String userId) {
    if (!_initialized) return null;
    final key = 'groups_$userId';
    final cached = _box.get(key);
    if (cached == null) return null;

    try {
      final jsonList = jsonDecode(cached) as List;
        return jsonList.map((jsonStr) {
    final m = jsonDecode(jsonStr) as Map<String, dynamic>;
    return GroupEntity(
      id: m['id'] ?? '',
      name: m['name'] ?? '',
      description: m['description'],
      createdBy: m['createdBy'] ?? '',
      createdAt: DateTime.parse(m['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: m['isActive'] ?? true,
      habitsCount: m['habitsCount'] ?? 0,
    );
  }).toList();
    } catch (e) {
      _box.delete(key);
      return null;
    }
  }

  @override
  Future<void> cacheGroups(String userId, List<GroupEntity> groups) async {
    await init();
    final key = 'groups_$userId';
    final jsonList = groups.map((g) => jsonEncode({
      'id': g.id,
      'name': g.name,
      'description': g.description,
      'createdBy': g.createdBy,
      'createdAt': g.createdAt.toIso8601String(),
      'isActive': g.isActive,
      'habitsCount': g.habitsCount,
    })).toList();
    await _box.put(key, jsonEncode(jsonList));
  }

  @override
  Future<void> invalidateGroups(String userId) async {
    if (!_initialized) return;
    await _box.delete('groups_$userId');
  }
}