import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_keeper/validate.dart';
import 'package:time_keeper/converter.dart';
import 'package:time_keeper/data_input_pop-up.dart';
import 'package:time_keeper/results_pop-up.dart';

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
  
  final validator = Validator();
  final converter = TimeConverter();

  Future<void> _submitTask() async {
    try {
      DocumentReference newTaskRef = FirebaseFirestore.instance.collection('tasks').doc();

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


      await newTaskRef.set({
        'date': _dateController.text,
        'from': _fromController.text,
        'to': _toController.text,
        'task': _taskController.text,
        'tag': _tagController.text,
      });

      setState(() {
        _message = 'Task submitted: ${_taskController.text} from ${_fromController.text} to ${_toController.text} on ${_dateController.text} with tag ${_tagController.text}.';
        print(_message);
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        print(_message);
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _showSubmitBox() async {
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
          submitTask: _submitTask,
        );
      },
    );
  }

  Future<void> _searchTasks() async {

    try{
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
                    controller: _searchTaskController,
                    decoration: InputDecoration(labelText: 'Task'),
                  ),
                  TextField(
                    controller: _searchTagController,
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
                  Navigator.of(context).pop();
                  _getResults(); // Call the search function
                },
                child: Text('Search'),
              ),
            ],
          );
        },
      );
    }
    catch (e) {
      setState(() {
        _message = 'Error searching tasks: $e';
        print(_message);
      });
    }
  }

  Future<void> _getResults() async {
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

    try {
      var results = ResultsPopup();
      results.show(context, tasks).then((message) {
        setState(() {
          _message = message;
          print(_message);
        });
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        print(_message);
      });
    }



  } catch (e) {
    setState(() {
      _message = 'Error searching tasks: $e';
      print(_message);
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
                _showSubmitBox();
              },
              child: Text('Add Task'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getResults,
              child: Text('Show All Tasks'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchTasks();
              },
              child: Text('Search Tasks'),
            ),
            SizedBox(height: 20),
            Text(_message, key: const Key('message')),
          ],
        ),
      ),
    );
  }
}
