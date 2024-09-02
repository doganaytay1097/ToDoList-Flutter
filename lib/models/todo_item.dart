class TodoItem {
  String task;
  int status; // 0: boş, 1: tamamlanmış, 2: yapılmamış
  String category;

  TodoItem({
    required this.task,
    required this.status,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'status': status,
      'category': category,
    };
  }

  static TodoItem fromMap(Map<String, dynamic> map) {
    return TodoItem(
      task: map['task'],
      status: map['status'],
      category: map['category'],
    );
  }
}
