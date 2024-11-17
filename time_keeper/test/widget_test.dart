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



void main() {


  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap the 'Add Task' button and trigger a frame.
    await tester.tap(find.text('Add Task'));
    await tester.pump();

    // Verify that the dialog is displayed.
    await expectLater(find.text('Submit Task'), findsOneWidget);

    // Enter task details in the dialog.
    await tester.enterText(find.byType(TextField).at(0), 'today');
    await tester.enterText(find.byType(TextField).at(1), '10:00');
    await tester.enterText(find.byType(TextField).at(2), '11:00');
    await tester.enterText(find.byType(TextField).at(3), 'Test Task');
    await tester.enterText(find.byType(TextField).at(4), 'Test Tag');

    // Verify that the task details are entered.
    await expectLater(find.text('today'), findsOneWidget);
    await expectLater(find.text('10:00'), findsOneWidget);
    await expectLater(find.text('11:00'), findsOneWidget);
    await expectLater(find.text('Test Task'), findsOneWidget);
    await expectLater(find.text('Test Tag'), findsOneWidget);

    // Submit the task.
    await tester.tap(find.text('Submit Task'));
    await tester.pump();

    // Verify that the message text widget has the right text.
    await expectLater(find.byKey(Key('messageText')), findsOneWidget);
    await expectLater(find.text('Task submitted: Test Task from 10:00 to 11:00 on today with tag Test Tag.'), findsOneWidget);

    // Verify that the dialog is closed.
    await expectLater(find.text('Submit Task'), findsNothing);

    // Verify that the task is in the database.
    await tester.tap(find.text('Show All Tasks'));
    await tester.pump();

    // Verify that the task is displayed in the list.
    //await expectLater(find.byWidgetPredicate((widget) => widget is Text && widget.data == 'Test Task'), findsOneWidget);
  });
}