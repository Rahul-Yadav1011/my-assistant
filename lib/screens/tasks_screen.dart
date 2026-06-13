import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

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
    if (t.done) {
      // was done, now reopened — could reschedule, but keep simple
    } else {
      await NotificationService.instance.cancel(t.id!);
    }
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
      appBar: AppBar(title: const Text('Tasks')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(child: Text('No tasks yet.')),
                    ],
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (_, i) {
                      final t = _tasks[i];
                      return Dismissible(
                        key: ValueKey('task-${t.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _delete(t),
                        child: CheckboxListTile(
                          value: t.done,
                          onChanged: (_) => _toggleDone(t),
                          title: Text(
                            t.title,
                            style: TextStyle(
                              decoration: t.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '#${t.id} · ${DateFormat('EEE, MMM d · h:mm a').format(t.dueAt)}',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
