import 'package:flutter/material.dart';

class DataInputPopup extends StatelessWidget {
TextEditingController _dateController;
TextEditingController _fromController;
TextEditingController _toController;
TextEditingController _taskController;
TextEditingController _tagController;
bool _isAmPm;
String from_AM_PM;
String to_AM_PM;
Function _submitTask;

  DataInputPopup({
    required TextEditingController dateController,
    required TextEditingController fromController,
    required TextEditingController toController,
    required TextEditingController taskController,
    required TextEditingController tagController,
    required bool isAmPm,
    required String fromAMPM,
    required String toAMPM,
    required Function submitTask,
  })  : _dateController = dateController,
        _fromController = fromController,
        _toController = toController,
        _taskController = taskController,
        _tagController = tagController,
        _isAmPm = isAmPm,
        from_AM_PM = fromAMPM,
        to_AM_PM = toAMPM,
        _submitTask = submitTask;

  @override
  Widget build(BuildContext context) {
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
          },
          child: Text('Submit Task'),
        ),
      ],
    );
  }
}