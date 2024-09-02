import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';
import '../models/daily_record.dart';

class SharedPreferencesService {
  static const String _todosKey = 'todos';
  static const String _scoreKey = 'score';
  static const String _recordsKey = 'records';

  Future<void> saveTodos(List<TodoItem> todoList, int score) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todoStrings = todoList.map((item) => _todoToString(item)).toList();
    await prefs.setStringList(_todosKey, todoStrings);
    await prefs.setInt(_scoreKey, score);
  }

  Future<List<TodoItem>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todoStrings = prefs.getStringList(_todosKey) ?? [];
    return todoStrings.map((item) => _stringToTodo(item)).toList();
  }

  Future<int> loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scoreKey) ?? 0;
  }

  Future<void> saveDailyRecord(DailyRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];
    
    // Aynı gün için kayıt kontrolü ve güncelleme
    int recordIndex = records.indexWhere((r) => r.startsWith(record.date));
    if (recordIndex >= 0) {
      records[recordIndex] = _recordToString(record);  // Kaydı güncelle
    } else {
      records.add(_recordToString(record));  // Yeni kayıt ekle
    }
    await prefs.setStringList(_recordsKey, records);
  }

  Future<List<DailyRecord>> loadDailyRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];
    return records.map((item) => _stringToRecord(item)).toList();
  }

  Future<void> deleteDailyRecord(String date) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];
    records.removeWhere((r) => r.startsWith(date));
    await prefs.setStringList(_recordsKey, records);
  }

  String _todoToString(TodoItem todo) {
    return "${todo.task}::${todo.status}::${todo.category}";
  }

  TodoItem _stringToTodo(String str) {
    final split = str.split('::');
    return TodoItem(
      task: split[0],
      status: int.parse(split[1]),
      category: split[2],
    );
  }

  String _recordToString(DailyRecord record) {
    return "${record.date}::${record.score}";
  }

  DailyRecord _stringToRecord(String str) {
    final split = str.split('::');
    return DailyRecord(
      date: split[0],
      score: int.parse(split[1]),
    );
  }
}
