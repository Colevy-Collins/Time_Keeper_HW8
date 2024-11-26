import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_keeper/data_input_pop-up.dart';
import 'package:time_keeper/results_pop-up.dart';
import 'package:time_keeper/report_handler.dart';
import 'package:intl/intl.dart';

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
  final reports = ReportHandler();
  String _message = '';

  void _setMessage(String message) {
    setState(() {
      _message = message;
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResultsPopup(tasks: tasks); // Pass tasks directly
        },
      ).then((message) {
        setState(() {
          _message = message ?? ''; // Handle possible null return
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

  Future<void> _dateRangeReport(BuildContext context) async {
    final TextEditingController _startDateController = TextEditingController();
    final TextEditingController _endDateController = TextEditingController();
    String startDate = '';
    String endDate = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Date Range Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? selectedStartDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedStartDate != null) {
                      startDate = DateFormat('yyyy/MM/dd').format(selectedStartDate);
                      _startDateController.text = startDate;
                    } else {
                      _setMessage('Please select start dates');
                    }
                  },
                  child: Text('Select Start Date'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Start Date'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? selectedEndDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedEndDate != null) {
                      endDate = DateFormat('yyyy/MM/dd').format(selectedEndDate);
                      _endDateController.text = endDate;
                    } else {
                      _setMessage("Please select end dates");
                    }
                  },
                  child: Text('Select End Date'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'End Date'),
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
              onPressed: () async {
                if (startDate.isNotEmpty && endDate.isNotEmpty) {
                  List<QueryDocumentSnapshot> tasks = await reports.getDateRangeReport(startDate, endDate);

                  try {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ResultsPopup(tasks: tasks); // Pass tasks directly
                      },
                    ).then((message) {
                      _setMessage(message);
                    });
                  } catch (e) {
                    _setMessage('Error: $e');
                  }
                } else {
                  // Optionally show an error message
                  _setMessage('Please select both start and end dates');
                }
              },
              child: Text('Generate Report'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _timeSpentReport() async {
    try {
      Map<String, dynamic> timeSpentReport = await reports.getTimeSpentReport();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(

            title: Text('Time Spent Report'),
            content: SingleChildScrollView(
              child: Column(
                children: timeSpentReport.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text('${entry.value}'),
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
      _setMessage('Error generating time spent report: $e');
    }
  }

  Future<void> _reports() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reports'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement date range report logic here
                    _dateRangeReport(context);
                  },
                  child: Text('Date Range Report'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement time spent report logic here
                    _timeSpentReport();
                  },
                  child: Text('Time Spent Report'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
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
              onPressed: () async {
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
                _setMessage(results);
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
            ElevatedButton(
              onPressed: () {
                _reports();
              },
              child: Text('Reports'),
            ),
            SizedBox(height: 20),
            Text(_message, key: const Key('message')),
          ],
        ),
      ),
    );
  }
}
