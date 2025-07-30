import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Section/UserStat/user_statistics.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../controller/controller.dart';

class MyProgressSection extends GetView<HomeController> {
  const MyProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build my progress section
    return Padding(
      padding: EdgeInsets.only(
        left: StyleX.hPaddingApp,
        right: StyleX.hPaddingApp,
        bottom: 24,
      ),
      child: Column(
        children: [
          /// My progress label
          LabelX("My Progress", marginBottom: 12).fadeAnimation250,

          /// My progress content
          Obx(() {
            return UserStatisticsSection(
              statistics: controller.statistics.value,
            ).fadeAnimation300;
          }),
        ],
      ),
    );
  }
}
