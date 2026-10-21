import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';
import '../../../../../../Data/Enum/event_option.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class EventDetailsActionsButtonSection extends GetView<EventDetailsController> {
  const EventDetailsActionsButtonSection({super.key});

  /// Event details actions button section
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isShowActions.value) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Edit button
            FloatingActionButton(
              heroTag: "edit",
              onPressed: controller.onEdit,
              child: Icon(Icons.edit),
            ).fadeAnimation150,

            /// Spacer
            SizedBox(height: 12),

            /// Delete button
            FloatingActionButton(
              heroTag: "delete",
              backgroundColor: Theme.of(context).colorScheme.error,

              /// Delete icon
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onError,
              ),

              /// On pressed delete event
              onPressed: () async {
                final navigator = Navigator.of(context);
                final detailRoute = ModalRoute.of(context);

                /// Show bottom sheet delete event
                await bottomSheetX(
                  child: Builder(
                    builder: (sheetContext) {
                      final sheetRoute = ModalRoute.of(sheetContext);
                      Future<void> delete(EventOptionEX option) async {
                        if (!await controller.onDeleteEvent(option) ||
                            !navigator.mounted) {
                          return;
                        }
                        // Close only the routes that initiated this deletion. A
                        // dismissed sheet or a later route must not cause an
                        // unrelated page to be popped after acknowledgement.
                        for (final route in [sheetRoute, detailRoute]) {
                          if (route == null || !route.isActive) continue;
                          if (route.isCurrent) {
                            navigator.pop(true);
                          } else {
                            navigator.removeRoute(route, true);
                          }
                        }
                      }

                      return Obx(
                        /// Lock screen when loading
                        () => AbsorbPointer(
                          absorbing: controller.isLoading.value,
                          child: Column(
                            children: [
                              /// Warning image
                              Image.asset(ImageX.warning, width: 80, height: 80)
                                  .fadeAnimation150
                                  .marginOnly(bottom: 16, top: 14),

                              /// Warning text
                              TextX(
                                    "Are you sure you want to delete the event ?",
                                    textAlign: TextAlign.center,
                                    style: TextStyleX.titleSLarge,
                                  ).fadeAnimation150
                                  .marginSymmetric(horizontal: 50)
                                  .marginOnly(bottom: 16),

                              /// Delete single button
                              ButtonStateX(
                                state: controller.buttonStateDeleteSingle.value,
                                text: "Delete this event only",
                                marginVertical: 0,
                                onTap: () async {
                                  await delete(EventOptionEX.single);
                                },
                              ).fadeAnimation200.marginOnly(bottom: 8),

                              /// Delete future button
                              ButtonStateX.second(
                                state: controller.buttonStateDeleteFuture.value,
                                text: "Delete all future events",
                                marginVertical: 0,
                                onTap: () async {
                                  await delete(EventOptionEX.future);
                                },
                              ).fadeAnimation200.marginOnly(bottom: 8),

                              /// Delete all button
                              ButtonStateX.second(
                                state: controller.buttonStateDeleteAll.value,
                                text: "Delete all events",
                                marginVertical: 0,
                                onTap: () async {
                                  await delete(EventOptionEX.all);
                                },
                              ).fadeAnimation200.marginOnly(bottom: 16),

                              /// Cancel button
                              ButtonX.second(
                                text: "Cancel",
                                marginVertical: 0,
                                onTap: Get.back,
                              ).fadeAnimation250,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ).fadeAnimation150,
          ],
        );
      } else {
        return SizedBox();
      }
    });
  }
}
