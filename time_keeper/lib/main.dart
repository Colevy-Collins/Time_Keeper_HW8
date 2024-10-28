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

  String _message = '';

  Future<void> _submitTask() async {
    try {
      DocumentReference newTaskRef = FirebaseFirestore.instance.collection('tasks').doc();

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
          content: SingleChildScrollView(
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
              ],
            ),
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
                      content: SingleChildScrollView(
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
            Text(_message),
          ],
        ),
      ),
    );
  }
}
