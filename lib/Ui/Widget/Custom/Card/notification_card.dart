import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Data/Model/notification.dart';

import '../../../../Config/Translation/translation.dart';
import '../../../../Config/config.dart';
import '../../widget.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});
  final NotificationX notification;

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      radius: 10,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Notification icon
          Icon(
            IconX.notifications,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),

          /// Spacer
          SizedBox(width: 16),

          /// Notification content
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Notification time
                    TextX(
                      DateFormat(
                        'd MMMM . hh:mm a',
                        TranslationX.getLanguageCode,
                      ).format(DateTime.parse(notification.timecreated)),
                      style: TextStyleX.labelMedium,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),

                    /// Unread indicator
                    if (!notification.read)
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                  ],
                ),

                /// Spacer
                SizedBox(height: 8),

                /// Notification subject
                TextX(notification.subject, style: TextStyleX.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
