import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _searchDateController = TextEditingController();
  final TextEditingController _searchTagController = TextEditingController();
  final TextEditingController _searchTaskController = TextEditingController();
  String _message = '';
  

  Future<void> _showSubmitBox() async {
    String results = '';
    results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DataInputPopup(
          context: context,
          isEdit: false,
          data: {},
        );
      },
    );
    setState(() {
      _message = results;
      print(_message);
    });
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
