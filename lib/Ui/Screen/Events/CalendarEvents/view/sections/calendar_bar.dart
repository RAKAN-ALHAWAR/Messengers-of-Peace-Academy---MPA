import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/Translation/translation.dart';
import '../../../../../../Config/config.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class CalendarBarSection extends GetView<CalendarController> {
  const CalendarBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Calendar bar
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: StyleX.hPaddingApp,
        vertical: 12,
      ).copyWith(bottom: 24),
      decoration: BoxDecoration(gradient: ColorX.primaryGradient),
      child: Column(
        children: [
          /// Year and Month & Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Year and Month
              GestureDetector(
                onTap: () {
                  /// Show date picker
                  bottomSheetX(
                    child: DatePickerX(
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      selectedDate: controller.selectedDate.value,
                      firstDayOfWeek: DateTime.saturday,
                      onDateSelected: controller.onChangeDateFromPicker,
                    ),
                  );
                },

                /// Year and Month text and arrow down icon
                child: Row(
                  children: [
                    /// Year and Month text
                    Obx(
                      () => TextX(
                        DateFormat(
                          "MMMM yyyy",
                          TranslationX.getLanguageCode,
                        ).format(controller.selectedDate.value),
                        style: TextStyleX.labelLarge,
                        color: Colors.white,
                      ),
                    ),

                    /// Spacer
                    SizedBox(width: 8),

                    /// Arrow down icon
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),

              /// Control Buttons
              Row(
                children: [
                  /// Previous week button
                  GestureDetector(
                    onTap: controller.onPreviousWeek,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                  /// Spacer
                  SizedBox(width: 8),

                  /// Next week button
                  GestureDetector(
                    onTap: controller.onNextWeek,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).fadeAnimation150,

          /// Spacer
          SizedBox(height: 16),

          /// Week Days
          Obx(() {
            return Row(
              children: [
                /// Week days
                for (int i = 0; i < controller.weekDays.length; i++)
                  /// Week day card
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: i == controller.weekDays.length - 1 ? 0 : 4,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () {
                            controller.selectDay(controller.weekDays[i]);
                          },
                          child: Container(
                            width: 48,
                            height: 66,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  controller.isSelectedDay(
                                        controller.weekDays[i],
                                      )
                                      ? ColorX.goldGradient
                                      : null,
                              border: Border.all(
                                color:
                                    controller.isSelectedDay(
                                          controller.weekDays[i],
                                        )
                                        ? Colors.white
                                        : Colors.transparent,
                              ),
                              color:
                                  controller.isSelectedDay(
                                        controller.weekDays[i],
                                      )
                                      ? null
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                StyleX.radiusLg,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Day Name
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: TextX(
                                      controller.getShortDayName(
                                        controller.weekDays[i],
                                      ),
                                      style: TextStyleX.labelMedium,
                                      color:
                                          controller.isSelectedDay(
                                                controller.weekDays[i],
                                              )
                                              ? ColorX.yellow.shade900
                                              : Colors.white,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  /// Spacer
                                  SizedBox(height: 7),

                                  /// Day Number
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: TextX(
                                      "${controller.weekDays[i].day}",
                                      style: TextStyleX.labelMedium,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          controller.isSelectedDay(
                                                controller.weekDays[i],
                                              )
                                              ? ColorX.yellow.shade900
                                              : Colors.white,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ).fadeAnimation200;
          }),
        ],
      ),
    );
  }
}
