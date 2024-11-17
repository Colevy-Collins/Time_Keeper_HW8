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
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Tap the 'Add Task' button and trigger a frame.
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      await expectLater(find.text('Submit Task'), findsOneWidget);

      // Enter task details in the dialog.
      await tester.enterText(find.byType(TextField).at(0), '2024/11/11');
      await tester.enterText(find.byType(TextField).at(1), '10:00');
      await tester.enterText(find.byType(TextField).at(2), '11:00');
      await tester.enterText(find.byType(TextField).at(3), 'Test Task');
      await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

      // Verify that the task details are entered.
      await expectLater(find.text('2024/11/11'), findsOneWidget);
      await expectLater(find.text('10:00'), findsOneWidget);
      await expectLater(find.text('11:00'), findsOneWidget);
      await expectLater(find.text('Test Task'), findsOneWidget);
      await expectLater(find.text('Test Tag'), findsOneWidget);

      // Submit the task.
      await tester.tap(find.text('Submit Task'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      await expectLater(find.text('Submit Task'), findsNothing);

      // Verify that the task is in the database.
      await tester.tap(find.text('Show All Tasks'));
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
      await tester.tap(find.text('Update Task'));
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

      // Verify that the task is displayed in the list.
      await expectLater(find.text('Test Task Update'), findsNothing);

    });
  });
}