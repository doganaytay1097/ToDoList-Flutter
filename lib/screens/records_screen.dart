import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../services/shared_preferences_service.dart';

class RecordsScreen extends StatelessWidget {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  Future<List<DailyRecord>> _loadRecords() async {
    return await _prefsService.loadDailyRecords();
  }

  void _deleteRecord(String date) async {
    await _prefsService.deleteDailyRecord(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Günlük Kayıtlar'),
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
        child: FutureBuilder<List<DailyRecord>>(
          future: _loadRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Bir hata oluştu'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Kayıtlı gün yok'));
            } else {
              final records = snapshot.data!;
              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                    title: Text(record.date),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Puan: ${record.score}"),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteRecord(record.date);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${record.date} silindi')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
