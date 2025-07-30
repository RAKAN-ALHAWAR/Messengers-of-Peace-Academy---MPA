part of '../../widget.dart';

class DatePickerX extends StatefulWidget {
  final DateTime? lastDate;
  final DateTime? firstDate;
  final DateTime? initialDate;
  final DateTime? selectedDate;
  final List<DateTime> selectedDates;
  final Function(DateTime) onDateSelected;
  final bool readOnly;
  final EdgeInsets margin;

  final int firstDayOfWeek; // New property to specify the first day of the week
  late final Locale locale;
  final List<String>? weekdayLabels; // New property for custom weekday labels
  final List<DateTime> blockedDates;

  final double heightBetweenWeekAndDays;
  final double heightBetweenYearAndWeek;
  final double heightBetweenItemsOfDays;

  final EdgeInsets dayMargin;
  final EdgeInsets dayPadding;
  final EdgeInsets weekPadding;
  final EdgeInsets monthPadding;
  final EdgeInsets yearPadding;

  final Color? todayColor;
  final Color? blockedDayColor;
  final Color? dayColor;
  final Color? weekColor;
  final Color? monthColor;
  final Color? yearColor;

  final Color? dayDisabledColor;
  final Color? weekDisabledColor;
  final Color? monthDisabledColor;
  final Color? yearDisabledColor;

  final Color? selectedDayColor;
  final Color? selectedMonthColor;
  final Color? selectedYearColor;

  final TextStyle? todayTextStyle;
  final TextStyle? dayDisabledTextStyle;
  final TextStyle? blockedDayTextStyle;
  final TextStyle? dayTextStyle;
  final TextStyle? weekTextStyle;
  final TextStyle? monthTextStyle;
  final TextStyle? yearTextStyle;

  final TextStyle? selectedDayTextStyle;
  final TextStyle? selectedMonthTextStyle;
  final TextStyle? selectedYearTextStyle;

  final Color? todayBackgroundColor;
  final Color? dayBackgroundColor;
  final Color? dayDisabledBackgroundColor;
  final Color? blockedDayBackgroundColor;
  final Color? selectedDayBackgroundColor;

  final BorderRadius? todayBackgroundRadius;
  final BorderRadius? dayBackgroundRadius;
  final BorderRadius? dayDisabledBackgroundRadius;
  final BorderRadius? blockedDayBackgroundRadius;
  final BorderRadius? selectedDayBackgroundRadius;

  final IconData lastIcon;
  final IconData nextIcon;

  DatePickerX({
    super.key,
    this.initialDate,
    this.selectedDate,
    this.selectedDates = const [],
    required this.onDateSelected,
    Locale? locale,
    this.firstDayOfWeek = DateTime.saturday,
    this.weekdayLabels,
    this.blockedDates = const [],
    this.lastDate,
    this.firstDate,
    this.heightBetweenWeekAndDays = 16,
    this.heightBetweenYearAndWeek = 16,
    this.heightBetweenItemsOfDays = 12,
    this.dayMargin = const EdgeInsets.all(0),
    this.dayPadding = const EdgeInsets.all(8),
    this.weekPadding = const EdgeInsets.all(8),
    this.monthPadding = const EdgeInsets.all(8),
    this.yearPadding = const EdgeInsets.all(8),
    this.todayColor,
    this.blockedDayColor,
    this.dayColor,
    this.weekColor,
    this.monthColor,
    this.yearColor,
    this.dayDisabledColor,
    this.weekDisabledColor,
    this.monthDisabledColor,
    this.yearDisabledColor,
    this.selectedDayColor,
    this.selectedMonthColor,
    this.selectedYearColor,
    this.todayTextStyle,
    this.blockedDayTextStyle,
    this.dayDisabledTextStyle,
    this.dayTextStyle,
    this.weekTextStyle,
    this.monthTextStyle,
    this.yearTextStyle,
    this.selectedDayTextStyle,
    this.selectedMonthTextStyle,
    this.selectedYearTextStyle,
    this.todayBackgroundColor,
    this.dayBackgroundColor,
    this.dayDisabledBackgroundColor,
    this.blockedDayBackgroundColor,
    this.selectedDayBackgroundColor,
    this.todayBackgroundRadius,
    this.dayBackgroundRadius,
    this.dayDisabledBackgroundRadius,
    this.blockedDayBackgroundRadius,
    this.selectedDayBackgroundRadius,
    this.lastIcon = Icons.arrow_back_ios,
    this.nextIcon = Icons.arrow_forward_ios,
    this.readOnly = false,
    this.margin = EdgeInsets.zero,
  }) {
    this.locale = locale ?? Locale(TranslationX.getLanguageCode);
  }

  @override
  State<DatePickerX> createState() => _DatePickerXState();
}

class _DatePickerXState extends State<DatePickerX> {
  late DateTime _displayedMonth;
  late DateTime? _selectedDate;
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    initializeDateFormatting(widget.locale.languageCode, null);
    _displayedMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.selectedDate ?? widget.initialDate;
    _selectedDates =
        widget.selectedDates.isNotEmpty
            ? widget.selectedDates
            : (widget.selectedDate != null ? [widget.selectedDate!] : []);
    super.initState();
  }

  void _nextMonth() {
    if (widget.lastDate == null ||
        _displayedMonth.month < widget.lastDate!.month + 1 ||
        _displayedMonth.year < widget.lastDate!.year) {
      setState(() {
        _displayedMonth = DateTime(
          _displayedMonth.year,
          _displayedMonth.month + 1,
        );
      });
    }
  }

  void _previousMonth() {
    if (widget.firstDate == null ||
        _displayedMonth.month > widget.firstDate!.month ||
        _displayedMonth.year > widget.firstDate!.year) {
      setState(() {
        _displayedMonth = DateTime(
          _displayedMonth.year,
          _displayedMonth.month - 1,
        );
      });
    }
  }

  List<Widget> _buildDaysOfWeek() {
    List<String> daysOfWeek = [
      'sunday_short', // الأحد
      'monday_short', // الإثنين
      'tuesday_short', // الثلاثاء
      'wednesday_short', // الأربعاء
      'thursday_short', // الخميس
      'friday_short', // الجمعة
      'saturday_short', // السبت
    ];
    int firstDayIndex = widget.firstDayOfWeek % 7;
    daysOfWeek =
        daysOfWeek.skip(firstDayIndex).toList() +
        daysOfWeek.take(firstDayIndex).toList();

    return daysOfWeek.map((day) {
      return Center(
        child: TextX(
          day,
          style: widget.weekTextStyle ?? TextStyleX.bodyLarge,
          color:
              widget.weekColor ??
              widget.weekTextStyle?.color ??
              Theme.of(context).colorScheme.secondary,
          fontWeight: widget.weekTextStyle?.fontWeight ?? FontWeight.w400,
        ),
      );
    }).toList();
  }

  List<Widget> _buildCalendarDays() {
    int daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    int startingWeekday =
        (firstDayOfMonth.weekday - widget.firstDayOfWeek + 7) % 7;
    int daysInPreviousMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 0).day;

    List<Widget> days = [];
    List<Widget> dayRows = [];

    // Add days from previous month
    int prevMonthDaysToShow = startingWeekday;

    for (int i = prevMonthDaysToShow; i > 0; i--) {
      days.add(
        GestureDetector(
          onTap: () {},
          child: ContainerX(
            width: 40,
            height: 40,
            isBorder: false,
            color: widget.dayDisabledBackgroundColor,
            borderRadius: widget.dayDisabledBackgroundRadius,
            padding: widget.weekPadding,
            child: Center(
              child: TextX(
                '${daysInPreviousMonth - i + 1}',
                style: widget.dayDisabledTextStyle ?? TextStyleX.bodyLarge,
                color:
                    widget.dayDisabledColor ??
                    Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      );
    }

    // Add days from the current month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime now = DateTime.now();
      DateTime currentDate = DateTime(
        _displayedMonth.year,
        _displayedMonth.month,
        day,
      );
      bool isBlocked =
          widget.blockedDates.firstWhereOrNull(
            (data) => DateTime(
              data.year,
              data.month,
              data.day,
            ).isSameDate(currentDate),
          ) !=
          null;
      bool isDisabled =
          (widget.firstDate != null
              ? widget.firstDate!.toDateOnly.isAfter(currentDate)
              : false) ||
          (widget.lastDate != null
              ? widget.lastDate!.toDateOnly.isBefore(currentDate)
              : false);
      bool isToday = now.isSameDate(currentDate);
      bool isSelected =
          _selectedDate?.isSameDate(currentDate) ??
          false || _selectedDates.any((date) => date.isSameDate(currentDate));

      days.add(
        GestureDetector(
          onTap: () {
            if (!isBlocked && !isDisabled) {
              if (!widget.readOnly) {
                setState(() {
                  if (isSelected) {
                    _selectedDates.removeWhere(
                      (date) => date.isSameDate(currentDate),
                    );
                    if (_selectedDate?.isSameDate(currentDate) ?? false) {
                      _selectedDate =
                          _selectedDates.isNotEmpty
                              ? _selectedDates.first
                              : widget.initialDate ?? DateTime.now();
                    }
                  } else {
                    _selectedDate = currentDate;
                    _selectedDates.add(currentDate);
                  }
                });
              }
              widget.onDateSelected(currentDate);
            }
          },
          child: ContainerX(
            width: 40,
            height: 40,
            color:
                isSelected
                    ? widget.selectedDayBackgroundColor ??
                        Theme.of(context).primaryColor
                    : (isBlocked
                        ? widget.blockedDayBackgroundColor
                        : isDisabled
                        ? widget.dayDisabledBackgroundColor
                        : isToday
                        ? widget.todayBackgroundColor ?? Colors.transparent
                        : widget.dayBackgroundColor),
            borderRadius:
                isSelected
                    ? widget.selectedDayBackgroundRadius ??
                        BorderRadius.circular(100)
                    : (isBlocked
                        ? widget.blockedDayBackgroundRadius ??
                            BorderRadius.circular(100)
                        : isDisabled
                        ? widget.dayDisabledBackgroundRadius ??
                            BorderRadius.circular(100)
                        : isToday
                        ? widget.todayBackgroundRadius ??
                            BorderRadius.circular(100)
                        : widget.dayBackgroundRadius ??
                            BorderRadius.circular(100)),
            padding: widget.dayPadding,
            margin: widget.dayMargin,
            isBorder: isToday,
            borderColor: isToday ? Theme.of(context).primaryColor : null,
            child: Center(
              child: TextX(
                '$day',
                style:
                    isSelected
                        ? (widget.selectedDayTextStyle ?? TextStyleX.bodyLarge)
                        : (isBlocked
                            ? (widget.blockedDayTextStyle ??
                                TextStyleX.bodyLarge)
                            : isDisabled
                            ? (widget.dayDisabledTextStyle ??
                                TextStyleX.bodyLarge)
                            : isToday
                            ? widget.todayTextStyle
                            : (widget.dayTextStyle ?? TextStyleX.bodyLarge)),
                color:
                    isSelected
                        ? widget.selectedDayColor ?? Colors.white
                        : (isBlocked
                            ? widget.blockedDayColor ??
                                Theme.of(context).colorScheme.error
                            : isDisabled
                            ? widget.dayDisabledColor ??
                                Theme.of(context).colorScheme.secondary
                            : isToday
                            ? widget.todayColor ??
                                Theme.of(context).primaryColor
                            : widget.dayColor),
                fontWeight: !isBlocked && !isDisabled ? FontWeight.w400 : null,
              ),
            ),
          ),
        ),
      );

      if ((startingWeekday + day) % 7 == 0) {
        dayRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days,
          ),
        );
        days = [];
      }
    }

    // Add days from the next month
    int daysToShow = (startingWeekday + daysInMonth) % 7;
    if (daysToShow != 0) {
      for (int i = 1; i <= 7 - daysToShow; i++) {
        days.add(
          GestureDetector(
            onTap: () {},
            child: ContainerX(
              width: 40,
              height: 40,
              color: widget.dayDisabledBackgroundColor,
              borderRadius:
                  widget.dayDisabledBackgroundRadius ??
                  BorderRadius.circular(100),
              padding: widget.dayPadding,
              margin: widget.dayMargin,
              isBorder: false,
              child: Center(
                child: TextX(
                  '$i',
                  style: widget.dayDisabledTextStyle ?? TextStyleX.bodyLarge,
                  color:
                      widget.dayDisabledColor ??
                      Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        );
      }
    }

    if (days.isNotEmpty) {
      while (days.length < 7) {
        days.add(const Expanded(child: SizedBox()));
      }
      dayRows.add(
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: days),
      );
    }

    return dayRows;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextX(
              '${intl.DateFormat.MMM(widget.locale.toString()).format(_displayedMonth)} ${_displayedMonth.year}',
              style: widget.monthTextStyle ?? TextStyleX.labelLarge,
              color: widget.monthColor,
              fontWeight: widget.monthTextStyle?.fontWeight ?? FontWeight.w400,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _previousMonth,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(widget.lastIcon, size: 13),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(widget.nextIcon, size: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(height: widget.heightBetweenYearAndWeek),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildDaysOfWeek(),
          ),
        ),
        SizedBox(height: widget.heightBetweenWeekAndDays),
        Wrap(
          runSpacing: widget.heightBetweenItemsOfDays,
          alignment: WrapAlignment.spaceBetween,
          children: _buildCalendarDays(),
        ),
      ],
    );
  }
}
