import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

/// Hive-based storage. Works identically on Android and Web (uses IndexedDB
/// under the hood when targeting web).
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const _boxName = 'tasks_v1';
  static const _metaBoxName = 'tasks_meta_v1';
  static const _nextIdKey = 'next_id';

  Box<String>? _box;
  Box<int>? _metaBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
    _metaBox = await Hive.openBox<int>(_metaBoxName);
  }

  Box<String> get _tasksBox {
    final b = _box;
    if (b == null) {
      throw StateError('DatabaseService.init() not called');
    }
    return b;
  }

  Box<int> get _meta {
    final b = _metaBox;
    if (b == null) {
      throw StateError('DatabaseService.init() not called');
    }
    return b;
  }

  int _nextId() {
    final current = _meta.get(_nextIdKey, defaultValue: 1) ?? 1;
    _meta.put(_nextIdKey, current + 1);
    return current;
  }

  Future<int> insertTask(Task task) async {
    final id = _nextId();
    final withId = task.copyWith(id: id);
    await _tasksBox.put(id.toString(), jsonEncode(withId.toMap()));
    return id;
  }

  Future<List<Task>> getAllTasks({bool includeDone = true}) async {
    final tasks = _tasksBox.values
        .map((s) => Task.fromMap(jsonDecode(s) as Map<String, Object?>))
        .where((t) => includeDone || !t.done)
        .toList();
    tasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return tasks;
  }

  Future<List<Task>> getPendingTasks() => getAllTasks(includeDone: false);

  Future<Task?> getTask(int id) async {
    final s = _tasksBox.get(id.toString());
    if (s == null) return null;
    return Task.fromMap(jsonDecode(s) as Map<String, Object?>);
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('Cannot update task without id');
    }
    await _tasksBox.put(task.id.toString(), jsonEncode(task.toMap()));
  }

  Future<void> deleteTask(int id) async {
    await _tasksBox.delete(id.toString());
  }

  Future<void> markDone(int id, bool done) async {
    final t = await getTask(id);
    if (t == null) return;
    await updateTask(t.copyWith(done: done));
  }
}
