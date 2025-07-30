import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class NavCardsSection extends GetView<HomeController> {
  const NavCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build nav cards section
    return Padding(
      padding: EdgeInsets.only(
        left: StyleX.hPaddingApp,
        right: StyleX.hPaddingApp,
        bottom: 24,
      ),
      child:
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Blog nav card
                GestureDetector(
                  onTap: controller.onBlog,
                  child: ContainerX(
                    radius: StyleX.radiusLg,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    minWidth: 80,
                    maxWidth: 140,
                    child: Column(
                      children: [
                        /// Blog icon
                        Icon(
                          IconX.newsmode,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),

                        /// Spacer
                        SizedBox(height: 12),

                        /// Blog text
                        TextX("Blog", style: TextStyleX.labelMedium),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),

                /// Achievements nav card
                GestureDetector(
                  onTap: controller.onAchievements,
                  child: ContainerX(
                    radius: StyleX.radiusLg,
                    padding: EdgeInsets.all(16),
                    minWidth: 80,
                    maxWidth: 140,
                    child: Column(
                      children: [
                        /// Achievements icon
                        Icon(
                          IconX.social_leaderboard,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),

                        /// Spacer
                        SizedBox(height: 12),

                        /// Achievements text
                        TextX("Achievements", style: TextStyleX.labelMedium),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),

                /// My Courses nav card
                GestureDetector(
                  onTap: controller.onMyCourses,
                  child: ContainerX(
                    radius: StyleX.radiusLg,
                    padding: EdgeInsets.all(16),
                    minWidth: 80,
                    maxWidth: 140,
                    child: Column(
                      children: [
                        /// My Courses icon
                        Icon(
                          IconX.clinical_notes,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),

                        /// Spacer
                        SizedBox(height: 12),

                        /// My Courses text
                        TextX("My Courses", style: TextStyleX.labelMedium),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),

                /// My Certificates nav card
                GestureDetector(
                  onTap: controller.onMyCertificates,
                  child: ContainerX(
                    radius: StyleX.radiusLg,
                    padding: EdgeInsets.all(16),
                    minWidth: 80,
                    maxWidth: 140,
                    child: Column(
                      children: [
                        /// My Certificates icon
                        Icon(
                          IconX.verified,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),

                        /// Spacer
                        SizedBox(height: 12),

                        /// My Certificates text
                        TextX("My Certificates", style: TextStyleX.labelMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).fadeAnimation350,
    );
  }
}
