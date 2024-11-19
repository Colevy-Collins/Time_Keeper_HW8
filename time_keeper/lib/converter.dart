class TimeConverter {
 String convertTo24HourFormat(String time, String period) {
    final RegExp timeRegExp = RegExp(r'^(0[1-9]|1[0-2]):[0-5][0-9]$');
    if (!timeRegExp.hasMatch(time)) {
      throw FormatException('Enter a valid time in hh:mm format');
    }

    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (period.toLowerCase() == 'pm' && hour != 12) {
      hour += 12;
    } else if (period.toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

 String convertToAmPmFormat(String time) {
    final RegExp timeRegExp = RegExp(r'^\d{2}:\d{2}$');
    if (!timeRegExp.hasMatch(time)) {
      throw FormatException('Enter a valid time in hh:mm format');
    }

    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    String period = 'AM';

    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    } else if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}