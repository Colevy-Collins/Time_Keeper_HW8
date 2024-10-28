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

  // This widget is the root of your application.
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
      // Create a new document with a unique ID
      DocumentReference newTaskRef = FirebaseFirestore.instance.collection('tasks').doc();

      // Use the generated document ID to set data
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
            Text(_message),
          ],
        ),
      ),
    );
  }
}