# User Manual

# **Time Keeping App User Manual**

## **Project Description**

The Time Keeping App is designed to help users track their tasks with ease. It allows you to:

- **Add time entries** with details such as date, start time ("From"), end time ("To"), task name, and task tag for classification.
- **View, edit, or delete** existing time entries.
- **Search tasks** by date, task name, or a list of tags separated by commas.
- **Generate reports** to review task details:
    - **Date Range Report:** Displays tasks completed within a specified date range.
    - **Time Spent Report:** Summarizes time spent on tasks, grouped by tags.

## **How to Use the App**

### **1. Adding a Time Entry**

1. Click the **"Add Task"** button.
2. Fill in the following fields:
    - **Date:** Enter in `yyyy/mm/dd` format or type "today" for the current date.
    - **From:** Enter the start time in `hh:mm` format (24-hour or AM/PM time).
    - **To:** Enter the end time in `hh:mm` format (24-hour or AM/PM time).
    - **Task Name:** Provide a brief description of the task.
    - **Tag:** Assign a classification tag (e.g., "Work," "Personal").
3. If using AM/PM time, select the appropriate AM/PM button.
4. Click the **"Add Task"** button to save the entry.

### **2. Viewing Time Entries**

- To view all tasks:
    1. Click the **"Show All Task"** button.
- To search for specific tasks:
    1. Click the **"Search Task"** button.
    2. Enter search criteria:
        - **Date:** In `yyyy/mm/dd` format.
        - **Task Name:** Partial or full task name.
        - **Tag:** Enter tags separated by commas (e.g., "tag1,tag2,tag3").
    3. Click the **"Search Task"** button.

### **3. Editing a Time Entry**

1. Click the **"Show All Task"** button to view existing entries.
2. Locate the task to be edited and click its **"Edit"** button.
3. Update desired fields. Ensure all fields are filled.
    - If no changes are needed for a field, leave it unchanged.
4. Save the updated entry.

### **4. Deleting a Time Entry**

1. Click the **"Show All Task"** button.
2. Locate the task to be removed and click its **"Delete"** button.

### **5. Generating Reports**

### **A. Date Range Report**

1. Click the **"Reports"** button.
2. Select the **"Date Range Report"** option.
3. Choose the start and end dates:
    - Click **"Select Start Date"** and pick a date using the date picker.
    - Click **"Select End Date"** and pick a date using the date picker.
4. Click **"Generate Report"** to view tasks within the selected range.

### **B. Time Spent Report**

1. Click the **"Reports"** button.
2. Select the **"Time Spent Report"** option.
3. View the report, which includes:
    - Hours and minutes spent on each task type.
    - Total time grouped by tags.

## **Testing the App**

The app includes integration tests to ensure its reliability. Tests simulate user actions using a live Firebase connection.

### **Running Tests**

1. Run the following command in your terminal:
    
    ```
    flutter test integration_test/app_test.dart
    
    ```
    
2. Observe the app as it performs simulated actions.
3. Review the test results upon completion.

**Note:** Test failures may occur due to Firebase connection or loading issues.

## **Additional Notes**

- All times are converted to 24-hour format upon saving.
- Date and time validations are enforced during input.
- Ensure proper internet connectivity for Firebase features.