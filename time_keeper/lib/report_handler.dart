import 'package:cloud_firestore/cloud_firestore.dart';

class ReportHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getDateRangeReport(String startDate, String endDate) async {
    Query query = _firestore.collection('tasks')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate);

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  Future<Map<String, dynamic>> getTimeSpentReport() async {
    Query query = _firestore.collection('tasks');

    QuerySnapshot querySnapshot = await query.get();
    List<QueryDocumentSnapshot> tasks = querySnapshot.docs;

    Map<String, dynamic> timeSpentByTag = {};

    for (var task in tasks) {
      String tag = task['tag'] ?? 'unknown';
      String from = task['from'] ?? '00:00';
      String to = task['to'] ?? '00:00';

      int fromMinutes = int.parse(from.split(':')[0]) * 60 + int.parse(from.split(':')[1]);
      int toMinutes = int.parse(to.split(':')[0]) * 60 + int.parse(to.split(':')[1]);

      int timeSpent = (toMinutes - fromMinutes).abs();

      if (timeSpentByTag.containsKey(tag)) {
        timeSpentByTag[tag] = timeSpentByTag[tag]! + timeSpent;
      } else {
        timeSpentByTag[tag] = timeSpent;
      }
    }

    for (var key in timeSpentByTag.keys.toList()) {
      if (timeSpentByTag[key] == 0) {
        timeSpentByTag.remove(key);
      } else {
        int totalMinutes = timeSpentByTag[key]!;
        int hours = totalMinutes ~/ 60;
        int minutes = totalMinutes % 60;
        timeSpentByTag[key] = '$hours hours and $minutes minutes ($totalMinutes minutes total)';
      }
    }

    return timeSpentByTag;
  }

}