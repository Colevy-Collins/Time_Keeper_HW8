// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';



void main() async {

  await IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  group('end-to-end test', ()
  {
    testWidgets('end-to-end test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Tap the 'Add Task' button and trigger a frame.
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/11');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Select AM/PM
      await tester.tap(find.byType(Radio<bool>).at(1));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Radio<String>).at(1));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Radio<String>).at(3));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/11'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      await expectLater(find.text('Submit Task'), findsNothing);

      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task'), findsOneWidget);

      // Tap the 'Edit Task' button and trigger a frame.
      // Find the ListTile containing the task title 'Test Task'
      final taskTile = find.widgetWithText(ListTile, 'Test Task');

      // Ensure the ListTile is found
      await expectLater(taskTile, findsOneWidget);

      // Find the edit button within the ListTile
      final editButton = await find.descendant(
        of: taskTile,
        matching: find.byIcon(Icons.edit),
      );

      // Ensure the edit button is found
      await expectLater(editButton, findsOneWidget);

      // Tap the edit button
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/11'), findsOneWidget);
      await expectLater(find.text('22:00'), findsOneWidget);
      await expectLater(find.text('23:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsNWidgets(2));
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/12/12');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task Updated');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag Updated');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/12/12'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task Updated'), findsOneWidget);
      await expectLater(find.text('Test Tag Updated'), findsOneWidget);

      // Update the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();


      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Tap the 'Delete Task' button and trigger a frame.
      // Find the ListTile containing the task title 'Test Task'
      final taskTile2 = await find.widgetWithText(ListTile, 'Test Task Updated');

      // Ensure the ListTile is found
      await expectLater(taskTile2, findsOneWidget);

      // Find the edit button within the ListTile
      final deleteButton = await find.descendant(
        of: taskTile2,
        matching: find.byIcon(Icons.delete),
      );

      // Ensure the edit button is found
      await expectLater(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task Update'), findsNothing);

      ////////////////////////////////////////////////////////////
      // Add a task with today as the date

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), 'today');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task Today');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag Today');

      // Verify that the task details are entered.
      await expectLater(find.text('today'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task Today'), findsOneWidget);
      await expectLater(find.text('Test Tag Today'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      await expectLater(find.text('Submit Task'), findsNothing);

      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task Today'), findsOneWidget);

      // Delete the task
      // Find the ListTile containing the task title 'Test Task Today'
      final taskTile3 = await find.widgetWithText(ListTile, 'Test Task Today');

      // Ensure the ListTile is found
      await expectLater(taskTile3, findsOneWidget);

      // Find the delete button within the ListTile
      final deleteButton2 = await find.descendant(
        of: taskTile3,
        matching: find.byIcon(Icons.delete),
      );

      // Ensure the delete button is found
      await expectLater(deleteButton2, findsOneWidget);

      await tester.tap(deleteButton2);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task Today'), findsNothing);

      /////////////////////////////////////////////////
      //test data constaints for date and time
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024-11-11');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '09:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      await expectLater(find.text('Submit Task'), findsNothing);

      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task'), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024-11-11');
      await tester.enterText(find.byType(TextField).at(1), 'a');
      await tester.enterText(find.byType(TextField).at(2), '09:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      await expectLater(find.text('Submit Task'), findsNothing);

      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task'), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();


      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024-11-11');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), 'a');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      await expectLater(find.text('Submit Task'), findsNothing);

      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task'), findsNothing);

      /////////////////////////////////////////////////
      //test search functionality

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/11');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test 1');
      await tester.enterText(find.byType(TextField).at(4), 'Test 1');

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/11');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test 2');
      await tester.enterText(find.byType(TextField).at(4), 'Test 2');

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // tap the search button
      await tester.tap(find.text('Search Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Enter search details in the dialog.
      await tester.enterText(find.byType(TextField).at(2), 'Test 1, Test 2');

      // Submit the search.
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test 1'), findsOneWidget);
      await expectLater(find.text('Test 2'), findsOneWidget);

      //Delete the tasks
      // Find the ListTile containing the task title 'Test Task'
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find the ListTile containing the task title 'Test Task'
      await tester.tap(find.text('Show All Tasks'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      final taskTile4 = await find.widgetWithText(ListTile, 'Test 1');

      // Ensure the ListTile is found
      await expectLater(taskTile4, findsOneWidget);

      // Find the delete button within the ListTile
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();
      final deleteButton3 = await find.descendant(
        of: taskTile4,
        matching: find.byIcon(Icons.delete),
      );

      // Ensure the delete button is found
      await expectLater(deleteButton3, findsOneWidget);

      await tester.tap(deleteButton3);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find the ListTile containing the task title 'Test Task2'
      final taskTile5 = await find.widgetWithText(ListTile, 'Test 2');

      // Ensure the ListTile is found
      await expectLater(taskTile5, findsOneWidget);

      // Find the delete button within the ListTile
      final deleteButton4 = await find.descendant(
        of: taskTile5,
        matching: find.byIcon(Icons.delete),
      );

      // Ensure the delete button is found
      await expectLater(deleteButton4, findsOneWidget);

      await tester.tap(deleteButton4);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Show All Tasks"));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test 1'), findsNothing);
      await expectLater(find.text('Test 2'), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();


      /////////////////////////////////////////////////////
      //Test reports

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/01');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/01'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/02');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/02'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/03');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/03'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/04');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/04'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/10/01');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/10/01'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/12/01');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/12/01'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Date Range Report'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Start Date'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byWidgetPredicate(
            (widget) => widget is TextField && widget.readOnly != true,
      ), '11/01/2024');

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select End Date'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byWidgetPredicate(
            (widget) => widget is TextField && widget.readOnly != true,
      ), '11/03/2024');

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Report'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await expectLater(find.text('Test Task'), findsNWidgets(3));

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Time Spent Report'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      String testString = find.text('6 hours and 0 minutes (360 minutes total)').toString();
      await expectLater(testString.contains("6 hours and 0 minutes (360 minutes total)"), isTrue);

    });
  });

}