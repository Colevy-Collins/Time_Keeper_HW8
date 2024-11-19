import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_keeper/data_input_pop-up.dart';
import 'package:time_keeper/validate.dart';
import 'package:time_keeper/converter.dart';

class ResultsPopup {
  String message = '';

  Future<void> _deleteTask(String taskId, context) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    Navigator.of(context).pop(); // Close the dialog after deletion
  }

  Future<void> _editTask(String taskId, Map<String, dynamic> data, context) async {
    // Pre-fill the controllers with current values
    final TextEditingController _dateController = TextEditingController();
    final TextEditingController _fromController = TextEditingController();
    final TextEditingController _toController = TextEditingController();
    final TextEditingController _taskController = TextEditingController();
    final TextEditingController _tagController = TextEditingController();

    _dateController.text = data['date'];
    _fromController.text = data['from'];
    _toController.text = data['to'];
    _taskController.text = data['task'];
    _tagController.text = data['tag'];

    bool _isAmPm = false;
    String to_AM_PM = 'AM';
    String from_AM_PM = 'AM';

    final validator = Validator();
    final converter = TimeConverter();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DataInputPopup(
          dateController: _dateController,
          fromController: _fromController,
          toController: _toController,
          taskController: _taskController,
          tagController: _tagController,
          isAmPm: _isAmPm,
          fromAMPM: from_AM_PM,
          toAMPM: to_AM_PM,
          submitTask: () async {
              String date = validator.getCurrentDateIfToday(_dateController.text);
              validator.validateDate(date);
              _dateController.text = date;

              if (_isAmPm) {
                validator.validateTimeAmPm("${_fromController.text}" + " " + from_AM_PM);
                validator.validateTimeAmPm("${_toController.text}" + " " + to_AM_PM);
                _fromController.text = converter.convertTo24HourFormat(_fromController.text, from_AM_PM);
                _toController.text = converter.convertTo24HourFormat(_toController.text, to_AM_PM);
              } else {
                validator.validateTime(_fromController.text);
                validator.validateTime(_toController.text);
              }

              await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
                'date': _dateController.text,
                'from': _fromController.text,
                'to': _toController.text,
                'task': _taskController.text,
                'tag': _tagController.text,
              });
          },
        );
      },
    );
  }

  void show(BuildContext context, List<QueryDocumentSnapshot> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('All Tasks'),
          content: Container(
            width: 400, // Set the width you want here
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            try {
                              _editTask(taskId, data, context);
                            } catch (e) {
                              message = 'Error editing task: $e';
                            }
                            message = 'Task updated successfully.';
                            // Refresh the task list
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            try {
                              _deleteTask(taskId, context);
                            } catch (e) {
                              message = 'Error deleting task: $e';
                            }
                            message = 'Task deleted successfully.';
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
  }
}