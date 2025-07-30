import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../Core/core.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Other/html_widget.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class TestResultsView extends GetView<TestResultsController> {
  const TestResultsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: controller.quiz.name),
      body: SafeArea(
        child: FutureBuilderX(
          future: controller.getData,
          loading: const TestResultsLoading(),
          child:
              (data) => SingleChildScrollView(
                padding: StyleX.paddingApp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            /// Spacer
                            SizedBox(height: 24),

                            /// Quiz image
                            Image.asset(
                              controller.isSuccess ? ImageX.done : ImageX.error,
                              width: 160,
                            ).fadeAnimation150,

                            /// Spacer
                            SizedBox(height: 12),

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
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ).fadeAnimation150,
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ContainerX(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Center(
                            child: CircularPercentIndicator(
                              radius: 24.0,
                              lineWidth: 5.0,
                              animation: true,
                              percent:
                                  controller.quizResult.grade /
                                  controller.quizResult.maxgrade,
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor:
                                  controller.isSuccess
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                              center: TextX(
                                "%${(controller.quizResult.grade / controller.quizResult.maxgrade * 100).toInt()}",
                                style: TextStyleX.labelMedium,
                                textDirection: TextDirection.ltr,
                                color:
                                    controller.isSuccess
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                              ),
                              backgroundColor:
                                  controller.isSuccess
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer
                                      : Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextX(
                                  controller.isSuccess
                                      ? "Congratulations, you have successfully passed the test"
                                      : "Unfortunately! You did not pass the test",
                                  style: TextStyleX.bodyMedium,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      controller.isSuccess
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(context).colorScheme.error,
                                ),
                                SizedBox(height: 4),
                                TextX(
                                  controller.isSuccess
                                      ? "You can now proceed to the next lesson"
                                      : "You cannot access the next lesson until you pass this test.",
                                  style: TextStyleX.bodySmall,
                                  color:
                                      controller.isSuccess
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(context).colorScheme.error,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).fadeAnimation200,
                    SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: ContainerX(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextX(
                                    "Number of questions",
                                    style: TextStyleX.labelLarge,
                                  ),
                                  SizedBox(height: 4),
                                  TextX(
                                    "${controller.quizStartAttempt.totalQuestions}",
                                    style: TextStyleX.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ContainerX(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextX(
                                    "Time taken",
                                    style: TextStyleX.labelLarge,
                                  ),
                                  SizedBox(height: 4),
                                  TextX(
                                    FunctionX.formatDuration(
                                      Duration(seconds: controller.timeTaken),
                                    ),
                                    style: TextStyleX.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).fadeAnimation250,
                    SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: ContainerX(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextX(
                                    "Correct answers",
                                    style: TextStyleX.labelLarge,
                                  ),
                                  SizedBox(height: 4),
                                  TextX(
                                    "${controller.correctAnswers}",
                                    style: TextStyleX.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ContainerX(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextX(
                                    "Wrong answers",
                                    style: TextStyleX.labelLarge,
                                  ),
                                  SizedBox(height: 4),
                                  TextX(
                                    "${controller.wrongAnswers}",
                                    style: TextStyleX.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).fadeAnimation250,
                    ButtonX(
                      text:
                          controller.isSuccess
                              ? "Go to next lesson"
                              : "Retake the test",
                      onTap: controller.onTapButton,
                      marginVertical: 24,
                    ).fadeAnimation300,
                    TextX(
                      "Question answers",
                      style: TextStyleX.titleMedium,
                    ).fadeAnimation350,
                    SizedBox(height: 12),
                    for (
                      var i = 0;
                      i < controller.quizStartAttempt.questions.length;
                      i++
                    )
                      ContainerX(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 12),
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextX(
                              "${"Question".tr} ${i + 1} ${"of".tr} ${controller.quiz.totalQuestions}",
                              style: TextStyleX.labelMedium,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(height: 8),
                            HtmlWidgetX(
                              html:
                                  controller.quizStartAttempt.questions[i].text,
                              textStyle: TextStyleX.titleMedium,
                            ).fadeAnimation200,
                            SizedBox(height: 16),
                            for (
                              int answerIndex = 0;
                              answerIndex <
                                  controller
                                      .quizStartAttempt
                                      .questions[i]
                                      .answers
                                      .length;
                              answerIndex++
                            )
                              RadioButtonX(
                                value:
                                    controller
                                        .quizStartAttempt
                                        .questions[i]
                                        .answers[answerIndex],
                                groupValue: controller.selectedAnswers[i],
                                color:
                                    controller
                                                    .quizResult
                                                    .answers[i]
                                                    .selectedAnswerIndex ==
                                                answerIndex &&
                                            controller
                                                .quizResult
                                                .answers[i]
                                                .right
                                        ? (context.isDarkMode
                                            ? ColorX.successContainerDark
                                            : ColorX.successContainer)
                                        : controller
                                                    .quizResult
                                                    .answers[i]
                                                    .selectedAnswerIndex ==
                                                answerIndex &&
                                            controller
                                                    .quizResult
                                                    .answers[i]
                                                    .right ==
                                                false
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.errorContainer
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onInverseSurface,
                                borderColor:
                                    controller
                                                .quizResult
                                                .answers[i]
                                                .selectedAnswerIndex ==
                                            answerIndex
                                        ? (context.isDarkMode
                                            ? ColorX.successDark
                                            : ColorX.success)
                                        : null,
                                onChanged: (_) {},
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    bottom: 12,
                                    top: 12,
                                    end: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HtmlWidgetX(
                                        html:
                                            controller
                                                .quizStartAttempt
                                                .questions[i]
                                                .answers[answerIndex],
                                        textStyle: TextStyleX.bodyMedium,
                                      ),
                                      if (controller.selectedAnswers[i] ==
                                              controller
                                                  .quizStartAttempt
                                                  .questions[i]
                                                  .answers[answerIndex] &&
                                          controller
                                                  .quizResult
                                                  .answers[i]
                                                  .selectedAnswerIndex ==
                                              answerIndex &&
                                          controller
                                                  .quizResult
                                                  .answers[i]
                                                  .right ==
                                              false)
                                        TextX(
                                          "Incorrect answer",
                                          style: TextStyleX.bodyMedium,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ).marginOnly(top: 4),
                                      if (controller
                                                  .quizResult
                                                  .answers[i]
                                                  .selectedAnswerIndex ==
                                              answerIndex &&
                                          controller
                                              .quizResult
                                              .answers[i]
                                              .right)
                                        TextX(
                                          "Correct answer",
                                          style: TextStyleX.bodyMedium,
                                          color:
                                              context.isDarkMode
                                                  ? ColorX.successDark
                                                  : ColorX.success,
                                        ).marginOnly(top: 4),
                                    ],
                                  ),
                                ),
                              ).fadeAnimation250,
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
