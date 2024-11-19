class Validator {
  void validateTime(String time) {
    final RegExp timeRegExp = RegExp(r'^\d{2}:\d{2}$');
    if (!timeRegExp.hasMatch(time)) {
      throw FormatException('Enter a valid time in hh:mm format');
    }
  }

  void validateTimeAmPm(String time) {
    final RegExp timeRegExp = RegExp(r'^(0[1-9]|1[0-2]):[0-5][0-9] (AM|PM|am|pm|Am|Pm|aM|pM)$');
    if (!timeRegExp.hasMatch(time)) {
      throw FormatException('Enter a valid time in hh:mm AM/PM format');
    }
  }

  void validateDate(String date) {
    final RegExp dateRegExp = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (!dateRegExp.hasMatch(date)) {
      throw FormatException('Enter a valid date in yyyy/mm/dd format');
    }
  }


  String getCurrentDateIfToday(String date) {
    if (date.toLowerCase() == 'today') {
      final DateTime now = DateTime.now();
      return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    }
    return date;
  }
}