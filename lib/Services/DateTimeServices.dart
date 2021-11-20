class CustomDateTime {
  DateTime startDate;
  CustomDateTime() {
    startDate = DateTime.now();
  }

  void setStartDate(DateTime sd) {
    startDate = sd;
  }

  bool decideWhichDayToEnableStart(DateTime day) {
    if (day.isAfter(DateTime.now().subtract(
      Duration(days: 1),
    ))) {
      return true;
    }
    return false;
  }

  bool decideWhichDayToEnableEnd(DateTime day) {
    if (day.isAfter(startDate.subtract(Duration(days: 1)))) {
      return true;
    }
    return false;
  }
}
