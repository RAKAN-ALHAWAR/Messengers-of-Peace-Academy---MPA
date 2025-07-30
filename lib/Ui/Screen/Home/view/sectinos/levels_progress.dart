import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class LevelsProgressSection extends GetView<HomeController> {
  const LevelsProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build levels progress section
    return Column(
      children: [
        /// Levels progress label
        LabelX("Levels Progress", marginBottom: 12).fadeAnimation150,

        /// Levels progress container
        Container(
          height: 86,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 24),
          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            gradient: ColorX.gold2Gradient,
            borderRadius: BorderRadius.circular(StyleX.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              width: 1,
            ),
          ),

          /// Levels progress content
          child: Obx(() {
            return SizedBox(
              width: double.infinity,
              child: FittedBox(
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width -
                      22, // 22 = 11 right + 11 left
                  child: Column(
                    children: [
                      /// Levels progress bar
                      Stack(
                        children: [
                          /// Levels progress bar background
                          SizedBox(
                            height: 46,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: LinearProgressIndicator(
                                  value:
                                      controller.levels
                                          .where(
                                            (element) => element.isCompleted,
                                          )
                                          .length /
                                      controller.levels.length,
                                  backgroundColor: ColorX.yellow.shade100,
                                  color: ColorX.yellow.shade400,
                                  borderRadius: BorderRadius.circular(100),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Levels items
                                for (
                                  int i = 0;
                                  i < controller.levels.length;
                                  i++
                                )
                                  controller.levels[i].isCompleted
                                      /// Completed level item
                                      ? Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Image.asset(
                                          ImageX.badge2,
                                          width: 46,
                                          height: 46,
                                        ),
                                      )
                                      /// Uncompleted level item
                                      : Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 5,
                                        ),
                                        child: Stack(
                                          children: [
                                            /// Level shape
                                            Image.asset(
                                              ImageX.shape,
                                              width: 46,
                                              height: 46,
                                            ),

                                            /// Level lock icon
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Center(
                                                child:
                                                    controller.levels[i].isOpen
                                                        /// Completed level item
                                                        ? Container(
                                                          width: 15,
                                                          height: 15,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  100,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: CircleAvatar(
                                                              radius: 3.5,
                                                              backgroundColor:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                            ),
                                                          ),
                                                        )
                                                        /// Uncompleted level item
                                                        : Icon(
                                                          IconX.lock,
                                                          color: Colors.black,
                                                          size: 15,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      /// Levels numbers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Levels numbers
                            for (int i = 0; i < controller.levels.length; i++)
                              TextX(
                                (i + 1).toString(),
                                style: TextStyleX.labelSmall,
                                color:
                                    controller.levels[i].isCompleted
                                        ? ColorX.yellow.shade600
                                        : Colors.black,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ).fadeAnimation200,
      ],
    ).marginSymmetric(horizontal: StyleX.hPaddingApp);
  }
}
