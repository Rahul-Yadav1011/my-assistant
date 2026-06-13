class Task {
  final int? id;
  final String title;
  final String? notes;
  final DateTime dueAt;
  final bool done;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.notes,
    required this.dueAt,
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    int? id,
    String? title,
    String? notes,
    DateTime? dueAt,
    bool? done,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'due_at': dueAt.millisecondsSinceEpoch,
      'done': done ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static Task fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      dueAt: DateTime.fromMillisecondsSinceEpoch(map['due_at'] as int),
      done: (map['done'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
