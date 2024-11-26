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

Future<void> addTask(WidgetTester tester, int count, {required String date, required String fromTime, required String toTime, required String taskName, required String taskTag}) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add Task'));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();

  // Verify that the dialog is displayed.
  await expectLater(find.text('Submit Task'), findsOneWidget);

  // Enter task details in the dialog.
  await tester.enterText(find.byType(TextField).at(0), date);
  await tester.enterText(find.byType(TextField).at(1), fromTime);
  await tester.enterText(find.byType(TextField).at(2), toTime);
  await tester.enterText(find.byType(TextField).at(3), taskName);
  await tester.enterText(find.byType(TextField).at(4), taskTag);

  // Verify that the task details are entered.
  await expectLater(find.text(date), findsOneWidget);
  await expectLater(find.text(fromTime), findsOneWidget);
  await expectLater(find.text(toTime), findsOneWidget);
  await expectLater(find.text(taskName), findsNWidgets(count));
  await expectLater(find.text(taskTag), findsOneWidget);

}

Future<void> findAndTap(WidgetTester tester, String text) async {
  // Submit the task.
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> submitTask(WidgetTester tester) async {
  // Submit the task.
  await tester.pumpAndSettle();
  await findAndTap(tester, 'Submit Task');
  // Verify that the dialog is closed.
  await expectLater(find.text('Submit Task'), findsNothing);
}

Future<void> showAllAndFindText(WidgetTester tester, String text) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Show All Tasks'));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 2));
  await tester.pumpAndSettle();

  await expectLater(find.text(text), findsOneWidget);
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> showAllAndFindNothing(WidgetTester tester, String text) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Show All Tasks'));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();

  await expectLater(find.text(text), findsNothing);

  await tester.tap(find.text('Close'));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> findWidgetByTextUseDescendant(WidgetTester tester, String text, IconData icon) async {
  // Find the ListTile containing the task title 'Test Task'
  await tester.pumpAndSettle();
  final taskTile = await find.widgetWithText(ListTile, text);

  // Ensure the ListTile is found
  await expectLater(taskTile, findsOneWidget);

  // Find the edit button within the ListTile
  final button = await find.descendant(
    of: taskTile,
    matching: find.byIcon(icon),
  );

  // Ensure the edit button is found
  await expectLater(button, findsOneWidget);

  await tester.tap(button);
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() async {

  await IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tearDown(() {
    // Cleanup actions after each test
    TestWidgetsFlutterBinding.ensureInitialized().reset();
  });

    testWidgets('Data input test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Tap the 'Add Task' button and trigger a frame.
      await addTask(tester, 1,
          date: "2024/11/11",
          fromTime: "10:00",
          toTime: "11:00",
          taskName: "Test Task",
          taskTag: "Test Tag");

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

      // Submit the task.
      await submitTask(tester);

      // Verify that the task is in the database.
      await showAllAndFindText(tester, "Test Task");
      await findWidgetByTextUseDescendant(tester, "Test Task", Icons.edit);

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
      await submitTask(tester);

      await findAndTap(tester, 'Close');

      // Verify that the task is in the database.
      await showAllAndFindText(tester, "Test Task Updated");
      await findWidgetByTextUseDescendant(tester, "Test Task Updated", Icons.delete);
      await showAllAndFindNothing(tester, "Test Task Updated");

      /////////////////////////////////////////////////
      //test data constants for date and time


      /////////////////////////////////////////////////
      //test search functionality

      /////////////////////////////////////////////////////
      //Test reports



    });
    testWidgets('Today test', (WidgetTester tester) async{
      await tester.pumpWidget(const MyApp());

      await addTask(tester, 1,
          date: "today",
          fromTime: "10:00",
          toTime: "11:00",
          taskName: "Test Task Today",
          taskTag: "Test Tag Today");

      // Submit the task.
      await submitTask(tester);

      // Verify that the task is in the database.
      await showAllAndFindText(tester, "Test Task Today");

      // Delete the task
      await showAllAndFindText(tester, "Test Task Today");
      await findWidgetByTextUseDescendant(tester, "Test Task Today", Icons.delete);
      await showAllAndFindNothing(tester, "Test Task Today");
    });
    testWidgets('Constrain test', (WidgetTester tester) async{
      await tester.pumpWidget(const MyApp());

      await addTask(tester, 1,
          date: "2024-11-11",
          fromTime: "10:00",
          toTime: "11:00",
          taskName: "Test Task",
          taskTag: "Test Tag");

      // Submit the task.
      await submitTask(tester);

      // Verify that the task is in the database.
      await showAllAndFindNothing(tester, "Test Task");

      await addTask(tester, 1,
          date: "2024/11/11",
          fromTime: "a",
          toTime: "11:00",
          taskName: "Test Task",
          taskTag: "Test Tag");

      // Submit the task.
      await submitTask(tester);

      // Verify that the task is in the database.
      await showAllAndFindNothing(tester, "Test Task");

      await addTask(tester, 1,
          date: "2024/11/11",
          fromTime: "10:00",
          toTime: "a",
          taskName: "Test Task",
          taskTag: "Test Tag");

      // Submit the task.
      await submitTask(tester);

      // Verify that the task is in the database.
      await showAllAndFindNothing(tester, "Test Task");
    });
    testWidgets('Search test', (WidgetTester tester) async{
      await tester.pumpWidget(const MyApp());

      await addTask(tester, 1,
          date: "2024/11/11",
          fromTime: "10:00",
          toTime: "11:00",
          taskName: "Test Task 1",
          taskTag: "Test Tag 1");

      await submitTask(tester);

      await addTask(tester, 1,
          date: "2024/11/11",
          fromTime: "10:00",
          toTime: "11:00",
          taskName: "Test Task 2",
          taskTag: "Test Tag 2");

      await submitTask(tester);

      // tap the search button
      await findAndTap(tester, 'Search Tasks');

      // Enter search details in the dialog.
      await tester.enterText(find.byType(TextField).at(2), 'Test Tag 1, Test Tag 2');

      // Submit the search.
      await findAndTap(tester, 'Search');

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task 1'), findsOneWidget);
      await expectLater(find.text('Test Task 2'), findsOneWidget);

      //Delete the tasks
      // Find the ListTile containing the task title 'Test Task'
      await findAndTap(tester, 'Close');

      // Find the ListTile containing the task title 'Test Task'
      await findAndTap(tester, 'Show All Tasks');

      await showAllAndFindText(tester, "Test Task 1");
      await findWidgetByTextUseDescendant(tester, "Test Task 1", Icons.delete);

      await showAllAndFindText(tester, "Test Task 2");
      await findWidgetByTextUseDescendant(tester, "Test Task 2", Icons.delete);

      await showAllAndFindNothing(tester, "Test Task 1");
      await showAllAndFindNothing(tester, "Test Task 2");
    });
    testWidgets('Date Range Report test', (WidgetTester tester) async{
    await tester.pumpWidget(const MyApp());

    await addTask(tester, 1,
        date: "2024/11/01",
        fromTime: "10:00",
        toTime: "11:00",
        taskName: "Test Task 1",
        taskTag: "Test Tag");

    await submitTask(tester);

    await addTask(tester, 1,
        date: "2024/11/02",
        fromTime: "10:00",
        toTime: "11:00",
        taskName: "Test Task 2",
        taskTag: "Test Tag");

    await submitTask(tester);

    await addTask(tester, 1,
        date: "2024/11/03",
        fromTime: "10:00",
        toTime: "11:00",
        taskName: "Test Task 3",
        taskTag: "Test Tag");

    await submitTask(tester);

    await addTask(tester, 1,
        date: "2024/11/04",
        fromTime: "10:00",
        toTime: "11:00",
        taskName: "Test Task 4",
        taskTag: "Test Tag");

    await submitTask(tester);

    await addTask(tester, 1,
        date: "2024/10/01",
        fromTime: "10:00",
        toTime: "11:00",
        taskName: "Test Task 5",
        taskTag: "Test Tag");

    await submitTask(tester);

    await addTask(tester, 1,
        date: "2024/12/01",
        fromTime: "10:00",
        toTime: "11:00",
        taskName: "Test Task 6",
        taskTag: "Test Tag");

    await submitTask(tester);


    await findAndTap(tester, 'Reports');

    await findAndTap(tester, 'Date Range Report');

    await findAndTap(tester, 'Select Start Date');

    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.enterText(find.byWidgetPredicate(
          (widget) => widget is TextField && widget.readOnly != true,
    ), '11/01/2024');

    await findAndTap(tester, 'OK');

    await findAndTap(tester, 'Select End Date');

    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.enterText(find.byWidgetPredicate(
          (widget) => widget is TextField && widget.readOnly != true,
    ), '11/03/2024');

    await findAndTap(tester, 'OK');

    await findAndTap(tester, 'Generate Report');

    await showAllAndFindText(tester, "Test Task 1");
    await showAllAndFindText(tester, "Test Task 2");
    await showAllAndFindText(tester, "Test Task 3");

    await findAndTap(tester, 'Close');

    await findAndTap(tester, 'Cancel');
    });
    testWidgets('Time Spent Reports test', (WidgetTester tester) async{
      await tester.pumpWidget(const MyApp());

      await findAndTap(tester, 'Reports');

      await findAndTap(tester, 'Time Spent Report');

      String testString = find.text('6 hours and 0 minutes (360 minutes total)').toString();
      await expectLater(testString.contains("6 hours and 0 minutes (360 minutes total)"), isTrue);

      await findAndTap(tester, 'Close');
      await findAndTap(tester, 'Exit');
      await Future.delayed(Duration(seconds: 5));

      await findAndTap(tester, "Show All Tasks");
      await tester.pumpAndSettle();
      await findAndTap(tester, 'Close');

      await findAndTap(tester, "Show All Tasks");
      await tester.pumpAndSettle();
      await findAndTap(tester, 'Close');

      await showAllAndFindText(tester, "Test Task 1");
      await findWidgetByTextUseDescendant(tester, "Test Task 1", Icons.delete);

      await showAllAndFindText(tester, "Test Task 2");
      await findWidgetByTextUseDescendant(tester, "Test Task 2", Icons.delete);

      await showAllAndFindText(tester, "Test Task 3");
      await findWidgetByTextUseDescendant(tester, "Test Task 3", Icons.delete);

      await showAllAndFindText(tester, "Test Task 4");
      await findWidgetByTextUseDescendant(tester, "Test Task 4", Icons.delete);

      await showAllAndFindText(tester, "Test Task 5");
      await findWidgetByTextUseDescendant(tester, "Test Task 5", Icons.delete);

      await showAllAndFindText(tester, "Test Task 6");
      await findWidgetByTextUseDescendant(tester, "Test Task 6", Icons.delete);
    });
}