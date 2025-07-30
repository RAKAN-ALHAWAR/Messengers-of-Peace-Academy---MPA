import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Card/event_card.dart';
import '../../../../Widget/widget.dart';
import '../controller/controller.dart';
import 'sections/calendar_bar.dart';
import 'sections/loading.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Add event button
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onAddEvent,
        child: Icon(Icons.add),
      ),

      /// Body
      body: SafeArea(
        child: Column(
          children: [
            /// Calendar bar with background
            CalendarBarSection(),

            /// Events timeline
            Expanded(
              child: FutureBuilderX(
                future: controller.getData,

                /// Loading state
                loading: const CalendarEventsLoading(),

                /// Data state
                child: (_) {
                  return SingleChildScrollView(
                    padding: StyleX.paddingApp,
                    child: Column(
                      children: [
                        /// Events by hour timeline
                        for (int hour in controller.hours)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Hour text
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                width: 60,
                                child: TextX(
                                  controller.getHourShow(hour),
                                  style: TextStyleX.labelMedium,
                                ),
                              ).fadeAnimation150,

                              /// Spacer
                              SizedBox(width: 12),

                              /// Timeline events
                              Expanded(
                                child: Obx(() {
                                  return Column(
                                    children: [
                                      /// Hour separator
                                      Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.8),
                                        height: 2,
                                      ).fadeAnimation150,

                                      /// Check if there are no events
                                      if (controller
                                          .getEventByHour(hour)
                                          .isEmpty)
                                        SizedBox(height: 60),

                                      /// Events in each hour
                                      ...controller.getEventByHour(hour).map((
                                        event,
                                      ) {
                                        /// Get color
                                        MaterialColor color =
                                            controller
                                                .colorsCardEvent[controller
                                                    .indexColorCardEvent %
                                                controller
                                                    .colorsCardEvent
                                                    .length];
                                        controller.indexColorCardEvent++;

                                        /// Event card
                                        return EventCard(
                                          event: event,
                                          color: color,
                                          onTap: controller.onOpenEvent,
                                        ).fadeAnimation150;
                                      }),

                                      /// Spacer
                                      SizedBox(height: 16),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
