import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_keeper/validate.dart';
import 'package:time_keeper/converter.dart';

class DataInputPopup extends StatefulWidget {
  final BuildContext context;
  final Map<String, dynamic>? data;
  final String? taskId;
  final bool isEdit;

  DataInputPopup({
    required this.context,
    this.data,
    this.taskId,
    this.isEdit = false,
  });

  @override
  _DataInputPopupState createState() => _DataInputPopupState();
}

class _DataInputPopupState extends State<DataInputPopup> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  bool _isAmPm = false;
  String to_AM_PM = 'AM';
  String from_AM_PM = 'AM';

  final validator = Validator();
  final converter = TimeConverter();

  String _message = '';

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.data != null) {
      _dateController.text = widget.data!['date'] ?? '';
      _fromController.text = widget.data!['from'] ?? '';
      _toController.text = widget.data!['to'] ?? '';
      _taskController.text = widget.data!['task'] ?? '';
      _tagController.text = widget.data!['tag'] ?? '';
    }
  }

  Future<void> _submitTask() async {
    try {
      String date = validator.getCurrentDateIfToday(_dateController.text);
      validator.validateDate(date);
      _dateController.text = date;

      if (_isAmPm) {
        validator.validateTimeAmPm("${_fromController.text} $from_AM_PM");
        validator.validateTimeAmPm("${_toController.text} $to_AM_PM");
        _fromController.text =
            converter.convertTo24HourFormat(_fromController.text, from_AM_PM);
        _toController.text =
            converter.convertTo24HourFormat(_toController.text, to_AM_PM);
      } else {
        validator.validateTime(_fromController.text);
        validator.validateTime(_toController.text);
      }

      if (widget.isEdit) {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(widget.taskId)
            .update({
          'date': _dateController.text,
          'from': _fromController.text,
          'to': _toController.text,
          'task': _taskController.text,
          'tag': _tagController.text,
        });
        _message = 'Task updated: ${_taskController.text} from ${_fromController.text} to ${_toController.text} on ${_dateController.text} with tag ${_tagController.text}.';
      } else {
        DocumentReference newTaskRef =
        FirebaseFirestore.instance.collection('tasks').doc();
        await newTaskRef.set({
          'date': _dateController.text,
          'from': _fromController.text,
          'to': _toController.text,
          'task': _taskController.text,
          'tag': _tagController.text,
        });
        _message = 'Task submitted: ${_taskController.text} from ${_fromController.text} to ${_toController.text} on ${_dateController.text} with tag ${_tagController.text}.';
      }
    } catch (e) {
      _message = 'Error: $e';
    }
    Navigator.of(context).pop(_message);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Task' : 'Add Task'),
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
            Row(
              key: Key('time-format-row'),
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
                Text('AM/PM'),
              ],
            ),
            if (_isAmPm) ...[
              Text('From Time Format'),
              Row(
                children: [
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
              Text('To Time Format'),
              Row(
                children: [
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitTask,
          child: Text('Submit Task'),
        ),
      ],
    );
  }
}
