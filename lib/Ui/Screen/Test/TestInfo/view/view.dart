import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/statistics_card.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class TestInfoView extends GetView<TestInfoController> {
  const TestInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(StyleX.appBarHeight),
        child: Obx(() {
          return AppBarX(
            /// Change title based on initialization
            title: controller.isInit.value ? controller.quiz.name : "Test",
          );
        }),
      ),
      body: SafeArea(
        child: FutureBuilderX<void>(
          future: controller.getData,
          loading: TestInfoLoading(),
          child: (_) {
            return Padding(
              padding: StyleX.paddingApp,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Quiz image and name
                  Stack(
                    children: [
                      /// Background of quiz image
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.1, 0.7, 0.9, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.1, 0.7, 0.9, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Opacity(
                            opacity: context.isDarkMode ? 0.2 : 1,
                            child: Image.asset(
                              ImageX.background,
                              height: 220,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ).fadeAnimation100,

                      /// Quiz image and name
                      Column(
                        children: [
                          /// Quiz image
                          Image.asset(
                            ImageX.notepad,
                            width: 130,
                          ).fadeAnimation150,

                          /// Spacer
                          SizedBox(height: 24),

                          /// Quiz name
                          TextX(
                            controller.quiz.name,
                            textAlign: TextAlign.center,
                            style: TextStyleX.titleLarge,
                          ).fadeAnimation150,

                          /// Spacer
                          SizedBox(height: 4),

                          /// Quiz description
                          TextX(
                            controller.quiz.description,
                            textAlign: TextAlign.center,
                            style: TextStyleX.labelLarge,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ).fadeAnimation150,
                        ],
                      ),
                    ],
                  ),

                  /// Spacer
                  SizedBox(height: 24),

                  /// Quiz statistics
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: StatisticsCardX(
                            title: "Number of questions",
                            value: controller.quiz.totalQuestions.toString(),
                            subValue: "questions",
                            icon: IconX.live_help,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatisticsCardX(
                            title: "Pass rate",
                            value: controller.quiz.totalQuestions.toString(),
                            subValue: "%",
                            icon: IconX.verified,
                          ),
                        ),
                      ],
                    ),
                  ).fadeAnimation200,

                  /// Spacer
                  SizedBox(height: 24),

                  /// Start test button
                  ButtonX(
                    text: "Start the test",
                    onTap: controller.onStartTest,
                  ).fadeAnimation200,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
