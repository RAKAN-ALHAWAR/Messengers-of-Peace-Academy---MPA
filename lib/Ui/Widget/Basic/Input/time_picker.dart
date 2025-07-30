part of '../../widget.dart';

class TimeInputX extends StatefulWidget {
  final Function(int hours, int minutes, String amPm)?
  onChangeAsItems; // إرجاع نصوص
  final Function(TimeOfDay time)? onChange; // إرجاع كـ TimeOfDay
  final TimeOfDay? initialTime; // الوقت الابتدائي
  final Color? timeColor;
  final Color? activeColor; // لون النص عند التحديد
  final Color? inactiveColor; // لون النص عند عدم التحديد
  final EdgeInsets? padding; // المسافات بين العناصر
  final double width;
  final double height;
  final double spaceBetweenItems;

  const TimeInputX({
    super.key,
    this.onChangeAsItems,
    this.onChange,
    this.initialTime,
    this.activeColor,
    this.timeColor,
    this.inactiveColor,
    this.padding,
    this.width = 60,
    this.height = 120,
    this.spaceBetweenItems = 12,
  });

  @override
  State<TimeInputX> createState() => _TimeInputXState();
}

class _TimeInputXState extends State<TimeInputX> {
  late int _hours;
  late int _minutes;
  late String _amPm;
  late TimeOfDay _initialTime;

  @override
  void initState() {
    super.initState();
    _initialTime = widget.initialTime ?? TimeOfDay.now();
    _hours = _initialTime.hourOfPeriod;
    _minutes = _initialTime.minute;
    _amPm = _initialTime.period == DayPeriod.am ? 'AM' : 'PM';
  }

  // هذه الدالة تقوم بإرجاع التعديلات إلى الخارج
  void _notifyChange() {
    if (widget.onChangeAsItems != null) {
      widget.onChangeAsItems!(_hours, _minutes, _amPm);
    }

    if (widget.onChange != null) {
      int finalHour;

      if (_amPm == 'AM') {
        finalHour = _hours % 12; // في حالة AM، إذا كانت الساعة 12 تكون 0
      } else {
        finalHour = (_hours % 12) + 12; // في حالة PM، إذا كانت الساعة 12 تظل 12
      }
      widget.onChange!(TimeOfDay(hour: finalHour, minute: _minutes));
    }
  }

  // عنصر مخصص للساعات أو الدقائق
  Widget _buildNumberInput({
    required int value,
    required Function onIncrease,
    required Function onDecrease,
    required String label,
  }) {
    return ContainerX(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      color: ColorX.grey.shade50,
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              onIncrease();
              _notifyChange();
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.keyboard_arrow_up,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          TextX(
            label,
            style: TextStyleX.bodyLarge,
            fontWeight: FontWeight.w500,
            color: widget.timeColor,
          ),
          GestureDetector(
            onTap: () {
              onDecrease();
              _notifyChange();
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عنصر مخصص لـ AM/PM
  Widget _buildAmPmInput() {
    return ContainerX(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      color: Theme.of(context).cardTheme.color,
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _amPm = 'AM';
                _notifyChange();
              });
            },
            child: TextX(
              'AM',
              style: TextStyleX.bodyLarge,
              fontWeight: FontWeight.w500,
              color:
                  _amPm == 'AM'
                      ? widget.activeColor ?? Theme.of(context).primaryColor
                      : widget.inactiveColor ?? Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _amPm = 'PM';
                _notifyChange();
              });
            },
            child: TextX(
              'PM',
              style: TextStyleX.bodyLarge,
              fontWeight: FontWeight.w500,
              color:
                  _amPm == 'PM'
                      ? widget.activeColor ?? Theme.of(context).primaryColor
                      : widget.inactiveColor ?? Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // حقل AM/PM
        _buildAmPmInput(),

        // حقل الدقائق
        _buildNumberInput(
          value: _minutes,
          onIncrease: () {
            setState(() {
              _minutes = (_minutes + 1) % 60;
            });
          },
          onDecrease: () {
            setState(() {
              _minutes = (_minutes - 1) < 0 ? 59 : _minutes - 1;
            });
          },
          label: _minutes.toString().padLeft(2, '0'),
        ).marginSymmetric(horizontal: widget.spaceBetweenItems),

        // حقل الساعات
        _buildNumberInput(
          value: _hours,
          onIncrease: () {
            setState(() {
              _hours = (_hours + 1) % 13;
              if (_hours == 0) _hours = 1; // نظام 12 ساعة
            });
          },
          onDecrease: () {
            setState(() {
              _hours = (_hours - 1) == 0 ? 12 : _hours - 1;
            });
          },
          label: _hours.toString().padLeft(2, '0'),
        ),
      ],
    );
  }
}
