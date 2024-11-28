Project Description
===================
In this project you will find a time keeping app were you can add time entries with 
a date, from, to, task name, and task tag. From is the time you started the task and to is 
the time you finished the task. The task name is the name of the task you are working on and tag
is the classification you assign to the tag for grouping purposes. You can also view ,edit ,and delete
time entries. The app also allows you to search for tasks using a date, task name or a list of tags 
with each tag be search for separated by a comma. Finally, you can generate reports. One report
you can generate is a date range report, where you select two dates and every task done between those
date is displayed. The other report you can generate is a time spent report, where you will see the
hours, minutes and the total minutes spend doing each kind of task grouped by the tags on the tasks.

How to use
==========
Adding a time entry:
--------------------
Step 1: Click on the "Add Task" button.
Step 2: Fill in the date, from, to, task name, and tag fields.
Note: The date must be in the format yyyy/mm/dd, the from and to fields must be in the format hh:mm
You are able to enter today in the date field to automatically fill in the current date.
You can use 24 based time or AM/PM time. If you use AM/PM time, you must utilize the proper buttons at 
the bottom of the form. The time will be converted to 24 when you click the "Add Task" button.
Step 3: Click on the "Add Task" button.

Viewing time entries:
---------------------
Step 1: Click on the "Show All Task" button.
This will display all the time entries in the database.
Alternatively you can search for tasks. To search follow these steps:
Step 1: Click on the "Search Task" button.
Step 2: Fill in the date, task name, and tag fields.
Note: The date must be in the format yyyy/mm/dd. All times are in 24 based time.
You can enter a list of tags separated by a comma. (e.g. tag1,tag2,tag3)
Step 3: Click on the "Search Task" button.

Editing a time entry:
---------------------
Step 1: Click on the "Show All Task" button.
Step 2: Click on the "Edit" button of the task you want to edit.
Step 3: Change the fields you want to edit.
Note: The date must be in the format yyyy/mm/dd, the from and to fields must be in the format hh:mm
All fields must be filled in, if you do not wish to change a field, do not edit the current data which
will be filled in.

Deleting a time entry:
----------------------
Step 1: Click on the "Show All Task" button.
Step 2: Click on the "Delete" button of the task you want to delete.

Generating a Date Range Report:
--------------------
Step 1: Click on the "Reports" button.
Step 2: Click on the "Date Range Report" button.
Step 3: Click on the "Select Start Date" button.
Step 4: Use date picker to select start date and click "OK".
Step 5: Click on the "Select End Date" button.
Step 6: Use date picker to select end date and click "OK".
Step 7: Click on the "Generate Report" button.

Generating a Time Spent Report:
--------------------
Step 1: Click on the "Reports" button.
Step 2: Click on the "Time Spent Report" button.

Testing 
=======
Note: This project uses the integration test package to test the project with a live 
firebase connection.

To run the tests, use the following command:
flutter test integration_test/app_test.dart

This will run a test the simulate a user doing several actions with the app.
You will see the app function on your screen as the test runs.
Once done, you will see the results of the test.