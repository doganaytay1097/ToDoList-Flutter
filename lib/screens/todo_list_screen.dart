import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../models/daily_record.dart';
import '../services/shared_preferences_service.dart';
import 'records_screen.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  final List<TodoItem> _todoList = [];
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = 'İş';
  int _score = 0;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final List<String> _categories = [
    'İş',
    'Egzersiz',
    'Alışveriş',
    'Eğlence',
    'Diğer'
  ];

  final Map<String, IconData> _categoryIcons = {
    'İş': Icons.work,
    'Egzersiz': Icons.fitness_center,
    'Alışveriş': Icons.shopping_cart,
    'Eğlence': Icons.movie,
    'Diğer': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  _loadTodos() async {
    List<TodoItem> loadedTodos = await _prefsService.loadTodos();
    int loadedScore = await _prefsService.loadScore();
    setState(() {
      _todoList.addAll(loadedTodos);
      _score = loadedScore;
    });

    _checkNewDay();  // Yeni güne geçildiğinde önceki günün kaydını kilitle
  }

  _checkNewDay() async {
    String lastRecordedDay = (await _prefsService.loadDailyRecords())
        .map((record) => record.date)
        .reduce((a, b) => a.compareTo(b) > 0 ? a : b);

    if (lastRecordedDay != today) {
      _finalizePreviousDay();
    }
  }

  _finalizePreviousDay() {
    for (var item in _todoList) {
      if (item.status == 0) {
        item.status = 2; // Boş bırakılan görevleri kırmızı işaretle
        _score -= 10;
      }
    }
    _saveDailyRecord();  // Önceki günün kaydını kilitle ve sakla
    _todoList.clear();  // Yeni güne geçildiği için görevleri temizle
    _score = 0;  // Yeni güne puanı sıfırla
    _saveTodos();  // Yeni güne başlangıç olarak görevleri kaydet
  }

  _saveTodos() async {
    await _prefsService.saveTodos(_todoList, _score);
  }

  _saveDailyRecord() async {
    DailyRecord record = DailyRecord(date: today, score: _score);
    await _prefsService.saveDailyRecord(record);
  }

  _addTodo() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _todoList.add(TodoItem(
          task: _textController.text,
          status: 0,
          category: _selectedCategory,
        ));
        _saveTodos();
        _textController.clear();
        _selectedCategory = 'İş';
      });
      Navigator.of(context).pop();
    }
  }

  _removeTodoAt(int index) {
    setState(() {
      _updateScoreOnRemove(_todoList[index].status);
      _todoList.removeAt(index);
      _saveTodos();
    });
  }

  _updateScoreOnRemove(int status) {
    if (status == 1) {
      _score -= 10;
    } else if (status == 2) {
      _score += 10;
    }
  }

  _toggleStatus(int index) {
    setState(() {
      int previousStatus = _todoList[index].status;
      int newStatus = (previousStatus + 1) % 3;
      _todoList[index].status = newStatus;

      _updateScore(previousStatus, newStatus);
      _saveTodos();
    });
  }

  _updateScore(int previousStatus, int newStatus) {
    if (previousStatus == 1) {
      _score -= 10;
    } else if (previousStatus == 2) {
      _score += 10;
    }

    if (newStatus == 1) {
      _score += 10;
    } else if (newStatus == 2) {
      _score -= 10;
    }
  }

  _editTodoDialog(int index) {
    _textController.text = _todoList[index].task;
    _selectedCategory = _todoList[index].category;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.blueGrey[50],
      builder: (context) => _buildTodoInput(index: index),
    );
  }

  Widget _buildTodoInput({int? index}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Görev',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Kategori Seçin',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_categoryIcons[category], color: Colors.blue),
                          SizedBox(width: 10),
                          Text(category),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: index == null ? _addTodo : () => _updateTask(index),
            child: Text(index == null ? 'Ekle' : 'Güncelle'),
          ),
        ],
      ),
    );
  }

  _updateTask(int index) {
    setState(() {
      _todoList[index].task = _textController.text;
      _todoList[index].category = _selectedCategory;
      _saveTodos();
      _textController.clear();
      _selectedCategory = 'İş';
    });
    Navigator.of(context).pop();
  }

  _navigateToRecordsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecordsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              '$_score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _saveDailyRecord();  // Günlük kaydı kaydet
              _navigateToRecordsScreen();  // Kayıtlı günleri göster
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _todoList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _todoList.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            _removeTodoAt(index);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                _todoList[index].task,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _todoList[index].status == 1
                                      ? Colors.green
                                      : _todoList[index].status == 2
                                          ? Colors.red
                                          : Colors.black,
                                  decoration: _todoList[index].status == 1 ||
                                          _todoList[index].status == 2
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              leading: Icon(
                                _categoryIcons[_todoList[index].category],
                                color: Colors.blue,
                              ),
                              trailing: GestureDetector(
                                onTap: () => _toggleStatus(index),
                                child: Icon(
                                  _todoList[index].status == 1
                                      ? Icons.check_box
                                      : _todoList[index].status == 2
                                          ? Icons.cancel
                                          : Icons.crop_square,
                                  color: _todoList[index].status == 1
                                      ? Colors.green
                                      : _todoList[index].status == 2
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                              ),
                              onTap: () => _editTodoDialog(index),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Henüz bir görev eklenmedi.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _textController.clear();
          _selectedCategory = 'İş';
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.blueGrey[50],
            builder: (context) => _buildTodoInput(),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Görev Ekle'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
