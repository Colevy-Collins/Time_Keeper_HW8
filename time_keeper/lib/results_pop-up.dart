import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_keeper/data_input_pop-up.dart';


class ResultsPopup extends StatefulWidget {
  List<QueryDocumentSnapshot> tasks;

  ResultsPopup({Key? key, required this.tasks}) : super(key: key);

  @override
  _ResultsPopupState createState() => _ResultsPopupState();
}

class _ResultsPopupState extends State<ResultsPopup> {
  String resultMessage = '';

  Future<void> _deleteTask(String taskId) async {
    String message = '';
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      message = 'Task Deleted Successfully';
      setState(() {
        widget.tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      message = 'Error deleting task: $e';
    }
    if (message.isNotEmpty) {
      setState(() {
        resultMessage = message;
      });
    }
  }

  Future<void> _editTask(String taskId, Map<String, dynamic> data) async {
    String results = await showDialog(
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

    final task1 = await FirebaseFirestore.instance.collection('tasks').get();
    setState(() {
      widget.tasks = task1.docs;
    });

    if (results.isNotEmpty) {
      setState(() {
        resultMessage = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('All Tasks'),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: ListBody(
            children: widget.tasks.map((task) {
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
                      onPressed: () async {
                        await _editTask(taskId, data);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteTask(taskId);
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
            Navigator.of(context).pop(resultMessage);
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
