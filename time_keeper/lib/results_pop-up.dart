import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_keeper/data_input_pop-up.dart';
import 'package:time_keeper/validate.dart';
import 'package:time_keeper/converter.dart';

class ResultsPopup {

  Future<String> _deleteTask(String taskId, context) async {
    String message = '';
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      message = 'Task Deleted Successfully';
      Navigator.of(context).pop(message); // Close the dialog after deletion
    } catch (e) {
      message = 'Error deleting task: $e';
      Navigator.of(context).pop(message);
    }
    return message;
  }

  Future<String> _editTask(String taskId, Map<String, dynamic> data, context) async {
    // Pre-fill the controllers with current values

    String results = '';
    results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DataInputPopup(
          context: context,
          isEdit: true,
          data: data,
          taskId: taskId,
        );
      },
    );
    return results;
  }

  Future<String> show(BuildContext context, List<QueryDocumentSnapshot> tasks) async {
    String resultMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('All Tasks'),
          content: Container(
            width: 400,
            child: SingleChildScrollView(
              child: ListBody(
                children: tasks.map((task) {
                  Map<String, dynamic> data = task.data() as Map<String, dynamic>;
                  String taskId = task.id;

                  return ListTile(
                    title: Text(data['task'] ?? 'No Task Name'),
                    subtitle: Text('${data['date']} from ${data['from']} to ${data['to']} with tag ${data['tag']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async{
                            resultMessage = await _editTask(taskId, data, context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async{
                            resultMessage = await _deleteTask(taskId, context);

                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );

    return resultMessage;
  }

}