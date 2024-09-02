class DailyRecord {
  String date;
  int score;

  DailyRecord({
    required this.date,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'score': score,
    };
  }

  static DailyRecord fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      date: map['date'],
      score: map['score'],
    );
  }
}
