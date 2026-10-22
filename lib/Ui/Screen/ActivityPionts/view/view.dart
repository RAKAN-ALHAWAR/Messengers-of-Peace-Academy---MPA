import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/Model/activity_point.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Data/data.dart';
import '../../../Widget/Custom/Card/activity_points_card.dart';
import '../../../Widget/Basic/Utils/future_builder.dart';
import '../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class ActivityPiontsView extends GetView<ActivityPiontsController> {
  const ActivityPiontsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Activities and Points List'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX<List<ActivityPointX>>(
          future: controller.getData,
          requestKey: (controller, TranslationX.getLanguageCode),

          /// Loading state
          loading: const ActivityPiontsLoading(),

          /// Data state
          child: (data) {
            /// Empty message
            if (data.isEmpty) {
              return const EmptyMessage('No activities currently');
            }

            /// Content
            return ListView.builder(
              key: PageStorageKey((
                controller,
                LocalDataX.sessionRevision,
                TranslationX.getLanguageCode,
                'activity-catalog',
              )),
              padding: StyleX.paddingApp,
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextX(
                        'List of activities that give you points',
                        style: TextStyleX.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextX(
                        'Points description',
                        style: TextStyleX.bodyMedium,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                }
                final activity = data[index - 1];
                return ActivityPointsCard(
                  name: activity.activityName,
                  points: activity.points,
                  secondaryText: activity.note,
                ).fadeAnimation200;
              },
            );
          },
        ),
      ),
    );
  }
}
