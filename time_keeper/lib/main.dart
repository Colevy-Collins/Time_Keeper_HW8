import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _searchDateController = TextEditingController();
  final TextEditingController _searchTagController = TextEditingController();
  final TextEditingController _searchTaskController = TextEditingController();

  String _message = '';
  bool _isAmPm = false;
  String to_AM_PM = 'AM';
  String from_AM_PM = 'AM';

  void _validateDate(String date) {
  final RegExp dateRegExp = RegExp(r'^\d{4}/\d{2}/\d{2}$');
  if (!dateRegExp.hasMatch(date)) {
    throw FormatException('Enter a valid date in yyyy/mm/dd format');
  }
 }

  String _getCurrentDateIfToday(String date) {
    if (date.toLowerCase() == 'today') {
      final DateTime now = DateTime.now();
      return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    }
    return date;
  }

  void _validateTime(String time) {
    final RegExp timeRegExp = RegExp(r'^\d{2}:\d{2}$');
    if (!timeRegExp.hasMatch(time)) {
      throw FormatException('Enter a valid time in hh:mm format');
    }
  }

  void _validateTimeAmPm(String time) {
    final RegExp timeRegExp = RegExp(r'^(0[1-9]|1[0-2]):[0-5][0-9] (AM|PM|am|pm|Am|Pm|aM|pM)$');
    if (!timeRegExp.hasMatch(time)) {
      throw FormatException('Enter a valid time in hh:mm AM/PM format');
    }
  }

  String _convertTo24HourFormat(String time, String period) {
  final RegExp timeRegExp = RegExp(r'^(0[1-9]|1[0-2]):[0-5][0-9]$');
  if (!timeRegExp.hasMatch(time)) {
    throw FormatException('Enter a valid time in hh:mm format');
  }

  List<String> parts = time.split(':');
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);

  if (period.toLowerCase() == 'pm' && hour != 12) {
    hour += 12;
  } else if (period.toLowerCase() == 'am' && hour == 12) {
    hour = 0;
  }

  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

  String _convertToAmPmFormat(String time) {
  final RegExp timeRegExp = RegExp(r'^\d{2}:\d{2}$');
  if (!timeRegExp.hasMatch(time)) {
    throw FormatException('Enter a valid time in hh:mm format');
  }

  List<String> parts = time.split(':');
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);
  String period = 'AM';

  if (hour >= 12) {
    period = 'PM';
    if (hour > 12) {
      hour -= 12;
    }
  } else if (hour == 0) {
    hour = 12;
  }

  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
}

  Future<void> _submitTask() async {
    try {
      DocumentReference newTaskRef = FirebaseFirestore.instance.collection('tasks').doc();

      String date = _getCurrentDateIfToday(_dateController.text);
      _validateDate(date);
      _dateController.text = date;

      if (_isAmPm) {
        _validateTimeAmPm("${_fromController.text}" + " " + from_AM_PM);
        _validateTimeAmPm("${_toController.text}" + " " + to_AM_PM);
        _fromController.text = _convertTo24HourFormat(_fromController.text, from_AM_PM);
        _toController.text = _convertTo24HourFormat(_toController.text, to_AM_PM);
      } else {
        _validateTime(_fromController.text);
        _validateTime(_toController.text);
      }


      await newTaskRef.set({
        'date': _dateController.text,
        'from': _fromController.text,
        'to': _toController.text,
        'task': _taskController.text,
        'tag': _tagController.text,
      });

      setState(() {
        _message = 'Task submitted: ${_taskController.text} from ${_fromController.text} to ${_toController.text} on ${_dateController.text} with tag ${_tagController.text}.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      setState(() {
        _message = 'Task deleted successfully.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error deleting task: $e';
      });
    }
  }

  Future<void> _editTask(String taskId, Map<String, dynamic> data) async {
    // Pre-fill the controllers with current values
    _dateController.text = data['date'];
    _fromController.text = data['from'];
    _toController.text = data['to'];
    _taskController.text = data['task'];
    _tagController.text = data['tag'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: 'Date'),
                    ),
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(labelText: 'From'),
                    ),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(labelText: 'To'),
                    ),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(labelText: 'Task'),
                    ),
                    TextField(
                      controller: _tagController,
                      decoration: InputDecoration(labelText: 'Tag'),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: _isAmPm,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAmPm = value!;
                            });
                          },
                        ),
                        Text('24-hour'),
                        Radio<bool>(
                          value: true,
                          groupValue: _isAmPm,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAmPm = value!;
                              to_AM_PM = 'AM';
                              from_AM_PM = 'AM';
                            });
                          },
                        ),
                        Text('AM/PM    '),
                        if (_isAmPm) ...[
                          Column(
                            children: [
                              Text('From'),
                              Radio<String>(
                                value: 'AM',
                                groupValue: from_AM_PM,
                                onChanged: (String? value) {
                                  setState(() {
                                    from_AM_PM = value!;
                                  });
                                },
                              ),
                              Text('AM'),
                              Radio<String>(
                                value: 'PM',
                                groupValue: from_AM_PM,
                                onChanged: (String? value) {
                                  setState(() {
                                    from_AM_PM = value!;
                                  });
                                },
                              ),
                              Text('PM'),
                            ],
                          ),
                          Column(
                            children: [
                              Text('To'),
                              Radio<String>(
                                value: 'AM',
                                groupValue: to_AM_PM,
                                onChanged: (String? value) {
                                  setState(() {
                                    to_AM_PM = value!;
                                  });
                                },
                              ),
                              Text('AM'),
                              Radio<String>(
                                value: 'PM',
                                groupValue: to_AM_PM,
                                onChanged: (String? value) {
                                  setState(() {
                                    to_AM_PM = value!;
                                  });
                                },
                              ),
                              Text('PM'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String date = _getCurrentDateIfToday(_dateController.text);
                  _validateDate(date);
                  _dateController.text = date;

                  if (_isAmPm) {
                    _validateTimeAmPm("${_fromController.text}" + " " + from_AM_PM);
                    _validateTimeAmPm("${_toController.text}" + " " + to_AM_PM);
                    _fromController.text = _convertTo24HourFormat(_fromController.text, from_AM_PM);
                    _toController.text = _convertTo24HourFormat(_toController.text, to_AM_PM);
                  } else {
                    _validateTime(_fromController.text);
                    _validateTime(_toController.text);
                  }

                  await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
                    'date': _dateController.text,
                    'from': _fromController.text,
                    'to': _toController.text,
                    'task': _taskController.text,
                    'tag': _tagController.text,
                  });
                  setState(() {
                    _message = 'Task updated successfully.';
                  });
                } catch (e) {
                  setState(() {
                    _message = 'Error updating task: $e';
                  });
                }

                Navigator.of(context).pop(); // Close the edit dialog

                // Close the previous dialog before showing the updated tasks
                Navigator.of(context).pop(); // This closes the task list dialog if it's still open

                // Show the updated task list
                _showAllTasks(); // Refresh the task list
              },
              child: Text('Update Task'),
            ),
          ],
        );

      },
    );
  }

  Future<void> _showAllTasks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      List<QueryDocumentSnapshot> tasks = querySnapshot.docs;

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
                              _editTask(taskId, data);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteTask(taskId);
                              Navigator.of(context).pop(); // Close the dialog after deletion
                              _showAllTasks(); // Refresh the task list
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
    } catch (e) {
      setState(() {
        _message = 'Error retrieving tasks: $e';
      });
    }
  }

  Future<void> _searchTasks() async {
    try {
      Query query = FirebaseFirestore.instance.collection('tasks');

      // Add conditions based on input values
      if (_searchDateController.text.isNotEmpty) {
        query = query.where('date', isEqualTo: _searchDateController.text);
      }

      if (_searchTagController.text.isNotEmpty) {
        // Split the tags by comma and trim any extra whitespace
        List<String> tags = _searchTagController.text
            .split(',')
            .map((tag) => tag.trim())
            .toList();
        query = query.where('tag', whereIn: tags);
      }

      if (_searchTaskController.text.isNotEmpty) {
        query = query.where('task', isEqualTo: _searchTaskController.text);
      }

      QuerySnapshot querySnapshot = await query.get();
      List<QueryDocumentSnapshot> tasks = querySnapshot.docs;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Search Results'),
            content: SingleChildScrollView(
              child: ListBody(
                children: tasks.map((task) {
                  Map<String, dynamic> data = task.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['task'] ?? 'No Task Name'),
                    subtitle: Text(
                      '${data['date']} from ${data['from']} to ${data['to']} with tag ${data['tag']}',
                    ),
                  );
                }).toList(),
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
    } catch (e) {
      setState(() {
        _message = 'Error searching tasks: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Data Input'),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _dateController,
                                  decoration: InputDecoration(labelText: 'Date'),
                                ),
                                TextField(
                                  controller: _fromController,
                                  decoration: InputDecoration(labelText: 'From'),
                                ),
                                TextField(
                                  controller: _toController,
                                  decoration: InputDecoration(labelText: 'To'),
                                ),
                                TextField(
                                  controller: _taskController,
                                  decoration: InputDecoration(labelText: 'Task'),
                                ),
                                TextField(
                                  controller: _tagController,
                                  decoration: InputDecoration(labelText: 'Tag'),
                                ),
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      groupValue: _isAmPm,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isAmPm = value!;
                                        });
                                      },
                                    ),
                                    Text('24-hour'),
                                    Radio<bool>(
                                      value: true,
                                      groupValue: _isAmPm,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isAmPm = value!;
                                          to_AM_PM = 'AM';
                                          from_AM_PM = 'AM';
                                        });
                                      },
                                    ),
                                    Text('AM/PM    '),
                                    if (_isAmPm) ...[
                                      Column(
                                      children: [
                                        Text('From'),
                                        Radio<String>(
                                          value: 'AM',
                                          groupValue: from_AM_PM,
                                          onChanged: (String? value) {
                                            setState(() {
                                              from_AM_PM = value!;
                                            });
                                          },
                                        ),
                                        Text('AM'),
                                        Radio<String>(
                                          value: 'PM',
                                          groupValue: from_AM_PM,
                                          onChanged: (String? value) {
                                            setState(() {
                                              from_AM_PM = value!;
                                            });
                                          },
                                        ),
                                        Text('PM'),
                                      ],
                                      ),
                                      Column(
                                        children: [
                                          Text('To'),
                                          Radio<String>(
                                            value: 'AM',
                                            groupValue: to_AM_PM,
                                            onChanged: (String? value) {
                                              setState(() {
                                                to_AM_PM = value!;
                                              });
                                            },
                                          ),
                                          Text('AM'),
                                          Radio<String>(
                                            value: 'PM',
                                            groupValue: to_AM_PM,
                                            onChanged: (String? value) {
                                              setState(() {
                                                to_AM_PM = value!;
                                              });
                                            },
                                          ),
                                          Text('PM'),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _submitTask();
                            Navigator.of(context).pop();
                          },
                          child: Text('Add Task'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add Task'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAllTasks,
              child: Text('Show All Tasks'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Search Tasks'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchDateController,
                              decoration: InputDecoration(labelText: 'Date'),
                            ),
                            TextField(
                              controller: _searchTagController,
                              decoration: InputDecoration(labelText: 'Tag'),
                            ),
                            TextField(
                              controller: _searchTaskController,
                              decoration: InputDecoration(labelText: 'Task'),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _searchTasks(); // Call the search function
                          },
                          child: Text('Search'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Search Tasks'),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
