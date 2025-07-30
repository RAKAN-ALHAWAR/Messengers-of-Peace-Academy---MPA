import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import '../../../../Config/config.dart';
import '../../../Widget/Custom/Card/notification_card.dart';
import '../../../Widget/Custom/Other/empty_message.dart';
import '../../../Widget/widget.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(
        title: 'Notifications',
        backValue: controller.getCountUnreadNotifications,
      ),
      body: SafeArea(
        child: FutureBuilderX(
          future: controller.getData,
          loading: NotificationsLoading(),
          child: (_) {
            /// If there are no notifications, show empty message
            if (controller.notifications.isEmpty) {
              return EmptyMessage(
                "No notifications currently",
              ).fadeAnimation150;
            }

            /// If there are notifications, show them
            return Obx(
              () => Stack(
                children: [
                  SingleChildScrollView(
                    padding: StyleX.paddingApp,
                    child: Column(
                      children: [
                        /// Mark all as read button
                        GestureDetector(
                          onTap: controller.onMarkAllAsRead,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextX(
                                  "Mark All as Read",
                                  style: TextStyleX.labelLarge,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ).fadeAnimation150,

                        /// Spacer
                        SizedBox(height: 10),

                        /// Notifications list cards
                        for (var notification in controller.notifications)
                          NotificationCard(
                            notification: notification,
                          ).fadeAnimation200,
                      ],
                    ),
                  ),

                  /// Loading indicator
                  if (controller.isLoading.value)
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLowest
                          .withValues(alpha: 0.5),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
