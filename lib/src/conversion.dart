int intValue(dynamic intOrString) {
  if (intOrString is int) {
    return intOrString;
  } else if (intOrString is String) {
    return parseInt(intOrString);
  } else {
    throw ArgumentError(
        "parameter is neither int nor string: $intOrString");
  }
}

int parseInt(String intStr, [int defaultValue]) {
  int value = int.parse(intStr) ?? defaultValue;
  if (value == null) {
    throw ArgumentError("couldn't convert to int: $intStr");
  }
  return value;
}

bool boolValue(dynamic boolOrString) {
  if (boolOrString is bool) {
    return boolOrString;
  } else if (boolOrString is String) {
    if (boolOrString == "true") {
      return true;
    } else if (boolOrString == "false") {
      return false;
    } else {
      throw FormatException("couldn't convert to bool: $boolOrString");
    }
  } else {
    throw ArgumentError(
        "parameter is neither bool nor string: $boolOrString");
  }
}

DateTime dayValue(dynamic dateOrString) {
  int assertUpperBound(int upperBound, String iName, int i) {
    if (i < 1 || i > upperBound) {
      throw ArgumentError(
          "$iName has to be inbetween 1 and $upperBound but is $i");
    }
    return i;
  }

  if (dateOrString is DateTime) {
    return dateOrString;
  } else if (dateOrString is String) {
    var yearMonthDayStr = dateOrString.split("-");
    if (yearMonthDayStr.length == 3) {
      try {
        int year = parseInt(yearMonthDayStr[0]);
        int month = assertUpperBound(12, "month", parseInt(yearMonthDayStr[1]));
        int day = assertUpperBound(31, "day", parseInt(yearMonthDayStr[2]));
        return DateTime(year, month, day);
      } finally  {}
    }
    throw FormatException(
        "parameter should have format YYYY-MM-DD but is: $dateOrString");
  } else {
    throw ArgumentError(
        "parameter is neither bool nor string: $dateOrString");
  }
}

dynamic /*int/List<int>*/ yearRangeValue(dynamic obj) {
  var year;
  var years;
  if (obj is int) {
    year = obj;
  } else if (obj is List<int>) {
    years = obj;
  } else if (obj is String) {
    try {
      year = parseInt(obj);
    } catch (e) {
      years = obj.split(",").map(parseInt);
    }
  } else {
    throw ArgumentError(
        "parameter is neither int, List<int> nor string: $obj");
  }

  if (year != null) {
    return year;
  }

  if (years.length == 2) {
    return years;
  }
  throw ArgumentError(
      "yearRange as a List<int> should contain 2 elements but contains $years");
}
