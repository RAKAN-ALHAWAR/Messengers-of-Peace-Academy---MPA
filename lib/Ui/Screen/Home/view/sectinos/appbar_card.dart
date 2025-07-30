import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class AppBarCard extends GetView<HomeController> {
  const AppBarCard({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build app bar card
    return Container(
      margin: EdgeInsets.only(top: 6),
      padding: EdgeInsets.only(
        left: StyleX.hPaddingApp,
        right: StyleX.hPaddingApp,
        top: 10,
        bottom: 9,
      ),
      child: Row(
        children: [
          /// User Image
          ImageNetworkX(
            imageUrl: controller.app.user.value.image,
            height: 48,
            width: 48,
            radius: 100,
            fit: BoxFit.cover,
            failed: Center(
              child: Icon(
                Icons.person,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          /// Spacer
          SizedBox(width: 12),

          /// User Name and Points
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// User Name
                  TextX(
                    controller.app.user.value.fullName,
                    style: TextStyleX.titleMedium,
                    color: Colors.white,
                  ),

                  /// Points
                  GestureDetector(
                    onTap: controller.onPointsTap,
                    child: ContainerX(
                      radius: 100,
                      isBorder: true,
                      color: Colors.transparent,
                      borderColor: Colors.white,
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Points Icon
                          Image.asset(ImageX.point, height: 11, width: 11),

                          /// Points Text
                          TextX(
                            "${FunctionX.formatLargeNumber(controller.app.user.value.points)} ${"points".tr}",
                            style: TextStyleX.bodySmall,
                            color: Colors.white,
                          ).marginSymmetric(horizontal: 6),

                          /// Arrow Icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Spacer
          SizedBox(width: 12),

          /// Notifications Icon
          InkResponse(
            onTap: controller.onNotifications,
            child: Obx(
              () => Stack(
                clipBehavior: Clip.none,
                children: [
                  /// Notifications Icon
                  Icon(IconX.notifications, color: Colors.white, size: 26),

                  /// Unread Notifications Count
                  if (controller.unreadNotificationsCount.value > 0)
                    Positioned(
                      top: -6,
                      right: -2,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          /// Unread Notifications Count Text
                          child: TextX(
                            controller.unreadNotificationsCount.value
                                .toString(),
                            style: TextStyleX.labelSmall,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).fadeAnimation100;
  }
}
