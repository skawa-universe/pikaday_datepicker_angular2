import 'dart:async';
import 'dart:html';

import 'package:angular/core.dart';
import 'package:js/js.dart';
import 'package:pikaday_datepicker_angular2/src/pikaday.dart';
import 'package:pikaday_datepicker_angular2/src/pikaday_dart_helpers.dart';
import 'conversion.dart';

/// Angular2 component wrapper around the Pikaday-js lib. You will have to
/// link to pikaday.js (Get the latest version from it's
/// [GitHub page](https://github.com/dbushell/Pikaday) and if you want
/// a custom date format (which is highly likable) also to [moment.js](http://momentjs.com/)).
///
/// Attribute documentation adapted from the
/// [pikaday.js documentation](https://github.com/dbushell/Pikaday).
///
/// You can't set a container DOM node nore a callback, but you can listen to
/// dayChange to be informed about selected days (DateTime instances).

@Component(
    selector: 'pikaday',
    template: '<input type="text" #pikadayField id="{{id}}" class="{{cssClasses}}" placeholder="{{placeholder}}">',
    changeDetection: ChangeDetectionStrategy.OnPush)
class PikadayComponent implements AfterViewInit {
  static int _componentCounter = 0;
  final String id = "pikadayInput${++_componentCounter}";

  @ViewChild('pikadayField')
  Element pikadayField;

  /// css-classes to be set on the pikaday-inputfield via <input class="{{cssClasses}}>
  @Input()
  String cssClasses = "";

  /// Sets the placeholder of the pikaday-inputfield.
  @Input()
  String placeholder;

  Pikaday _pikaday;
  final _options = PikadayOptions();

  bool get _isInitPhase => _pikaday == null;

  /// Emits selected dates.
  final StreamController<DateTime> _dayChange = StreamController<DateTime>();

  @Output()
  Stream<DateTime> get dayChange => _dayChange.stream;

  /// Combines [PikadayOptions.defaultDate] with [PikadayOptions.setDefaultDate]. Look there for more info.
  @Input()
  set day(DateTime day) {
    if (_isInitPhase) {
      _options.defaultDate = day;
      _options.setDefaultDate = day != null;
    } else {
      var dayMillies = day?.millisecondsSinceEpoch;
      setPikadayMillisecondsSinceEpoch(_pikaday, dayMillies);
    }
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.bound]. Look there for more info.
  @Input()
  set bound(dynamic bound) {
    _options.bound = boolValue(bound);
  }

  /// Forwards to [PikadayOptions.position]. Look there for more info.
  @Input()
  set position(String position) {
    _options.position = position;
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.reposition]. Look there for more info.
  @Input()
  set reposition(dynamic reposition) {
    _options.reposition = boolValue(reposition);
  }

  /// Forwards to [PikadayOptions.format]. Look there for more info.
  @Input()
  set format(String format) {
    _options.format = format;
  }

  /// <int> or <String>. Forwards to [PikadayOptions.firstDay]. Look there for more info.
  @Input()
  set firstDay(dynamic firstDay) {
    _options.firstDay = intValue(firstDay);
  }

  /// <DateTime> or <String> with format YYYY-MM-DD. Forwards to [PikadayOptions.minDate]. Look there for more info.
  @Input()
  set minDate(dynamic minDate) {
    final minDateAsDateTime = dayValue(minDate);
    if (_isInitPhase) {
      _options.minDate = minDateAsDateTime;
    } else {
      var minDateMillies = minDateAsDateTime?.millisecondsSinceEpoch;
      setPikadayMinDateAsMillisecondsSinceEpoch(_pikaday, minDateMillies);
    }
  }

  /// <DateTime> or <String> with format YYYY-MM-DD. Forwards to [PikadayOptions.maxDate]. Look there for more info.
  @Input()
  set maxDate(dynamic maxDate) {
    final maxDateAsDateTime = dayValue(maxDate);
    if (_isInitPhase) {
      _options.maxDate = maxDateAsDateTime;
    } else {
      var maxDateMillies = maxDateAsDateTime?.millisecondsSinceEpoch;
      setPikadayMaxDateAsMillisecondsSinceEpoch(_pikaday, maxDateMillies);
    }
  }

  /// Forwards to [PikadayOptions.disableWeekends]. Look there for more info.
  @Input()
  set disableWeekends(dynamic disableWeekends) {
    _options.disableWeekends = boolValue(disableWeekends);
  }

  /// <int>, <List<int>> or <String> (single '1990' or double '1980,2020').
  /// Forwards to [PikadayOptions.yearRange]. Look there for more info.
  @Input()
  set yearRange(dynamic yearRange) {
    _options.yearRange = yearRangeValue(yearRange);
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.showWeekNumber]. Look there for more info.
  @Input()
  set showWeekNumber(dynamic showWeekNumber) {
    _options.showWeekNumber = boolValue(showWeekNumber);
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.isRTL]. Look there for more info.
  @Input()
  set isRTL(dynamic isRTL) {
    _options.isRTL = boolValue(isRTL);
  }

  /// Forwards to [PikadayOptions.i18n]. Look there for more info.
  @Input()
  set i18n(PikadayI18nConfig i18n) {
    _options.i18n = i18n;
  }

  /// Forwards to [PikadayOptions.yearSuffix]. Look there for more info.
  @Input()
  set yearSuffix(String yearSuffix) {
    _options.yearSuffix = yearSuffix;
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.showMonthAfterYear]. Look there for more info.
  @Input()
  set showMonthAfterYear(dynamic showMonthAfterYear) {
    _options.showMonthAfterYear = boolValue(showMonthAfterYear);
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.showDaysInNextAndPreviousMonths]. Look there for more info.
  @Input()
  set showDaysInNextAndPreviousMonths(dynamic showDaysInNextAndPreviousMonths) {
    _options.showDaysInNextAndPreviousMonths = boolValue(showDaysInNextAndPreviousMonths);
  }

  /// <int> or <String>. Forwards to [PikadayOptions.numberOfMonths]. Look there for more info.
  @Input()
  set numberOfMonths(dynamic numberOfMonths) {
    _options.numberOfMonths = intValue(numberOfMonths);
  }

  /// Forwards to [PikadayOptions.mainCalendar]. Look there for more info.
  /// permitted values: "left", "right";
  @Input()
  set mainCalendar(String mainCalendar) {
    if (mainCalendar == "right" || mainCalendar == "left") {
      _options.mainCalendar = mainCalendar;
    }
    throw ArgumentError("should only be 'left' or 'right', but was: $mainCalendar");
  }

  /// Forwards to [PikadayOptions.theme]. Look there for more info.
  @Input()
  set theme(String theme) {
    _options.theme = theme;
  }

  @override
  void ngAfterViewInit() {
    _options.field = pikadayField;
    _options.onSelect = allowInterop(([dateTimeOrDate]) {
      print('day: $dateTimeOrDate || ${dateTimeOrDate?.runtimeType}');
      var day;
      if (DateTime(1970, 1, 1) != dateTimeOrDate) {
        day = dateTimeOrDate is DateTime
            ? dateTimeOrDate
            : DateTime.fromMillisecondsSinceEpoch(getPikadayMillisecondsSinceEpoch(_pikaday));
      }
      if (day != _options.defaultDate) {
        if (day == null) {
          _pikaday.setDate(null);
        }
        _options.defaultDate = day;
        _dayChange.add(day);
      }
    });

    _pikaday = Pikaday(_options);

    // Currently Dart's DateTime is not correctly mapped to JS's Date
    // so they are converted to millies as transferred as int values.
    void workaroundDateTimeConversionIssue(
      DateTime day,
      DateTime minDate,
      DateTime maxDate,
    ) {
      if (day != null) {
        var millies = day.millisecondsSinceEpoch;
        setPikadayMillisecondsSinceEpoch(_pikaday, millies);
      }
      if (minDate != null) {
        var millies = minDate.millisecondsSinceEpoch;
        setPikadayMinDateAsMillisecondsSinceEpoch(_pikaday, millies);
      }
      if (maxDate != null) {
        var millies = maxDate.millisecondsSinceEpoch;
        setPikadayMaxDateAsMillisecondsSinceEpoch(_pikaday, millies);
      }
    }

    workaroundDateTimeConversionIssue(_options.defaultDate, _options.minDate, _options.maxDate);
  }

  void clear() => _pikaday.setDate(null, true);
}
