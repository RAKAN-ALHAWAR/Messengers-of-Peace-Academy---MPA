import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../../Config/config.dart';
import '../../../../../Widget/Custom/Other/points_card.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class ProfileDetailsUnderAppbarSection
    extends GetView<ProfileDetailsController> {
  const ProfileDetailsUnderAppbarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: StyleX.hPaddingApp,
        right: StyleX.hPaddingApp,
        top: 2,
        bottom: 18,
      ),
      decoration: BoxDecoration(gradient: ColorX.primaryGradient),
      child: Obx(
        () =>
            Column(
              children: [
                Row(
                  children: [
                    ImageNetworkX(
                      imageUrl: controller.app.user.value.image,
                      height: 60,
                      width: 60,
                      radius: 100,
                      fit: BoxFit.cover,
                      failed: Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextX(
                            controller.app.user.value.fullName,
                            style: TextStyleX.titleMedium,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4),
                          TextX(
                            controller.app.user.value.email,
                            style: TextStyleX.labelMedium,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    InkResponse(
                      onTap: controller.onEditPersonalData,
                      child: Icon(IconX.edit, color: Colors.white),
                    ),
                  ],
                ),
                if (controller.currentBadge.value != null)
                  PointsCardX(
                    points: controller.app.user.value.points,
                    badge: controller.currentBadge.value!,
                  ).marginOnly(top: 16),
              ],
            ).fadeAnimation100,
      ),
    );
  }
}
