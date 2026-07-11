import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final t = await DatabaseService.instance.getAllTasks();
    if (!mounted) return;
    setState(() {
      _tasks = t;
      _loading = false;
    });
  }

  Future<void> _toggleDone(Task t) async {
    await DatabaseService.instance.markDone(t.id!, !t.done);
    if (!t.done) await NotificationService.instance.cancel(t.id!);
    _refresh();
  }

  Future<void> _delete(Task t) async {
    await DatabaseService.instance.deleteTask(t.id!);
    await NotificationService.instance.cancel(t.id!);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentIndex: 1),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Text('Tasks'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 120),
                    Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No tasks yet.\nAsk Mitra to "remind me to..."', textAlign: TextAlign.center))),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _tasks.length,
                    itemBuilder: (_, i) {
                      final t = _tasks[i];
                      return Dismissible(
                        key: ValueKey('task-${t.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(16)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _delete(t),
                        child: Card(
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            leading: Checkbox(value: t.done, onChanged: (_) => _toggleDone(t), shape: const CircleBorder()),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                decoration: t.done ? TextDecoration.lineThrough : null,
                                color: t.done ? Colors.white.withOpacity(0.5) : null,
                              ),
                            ),
                            subtitle: Text('#${t.id} · ${DateFormat('EEE, MMM d · h:mm a').format(t.dueAt)}'),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
