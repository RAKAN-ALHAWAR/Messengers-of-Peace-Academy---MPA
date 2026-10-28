import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Data/Model/quiz/answer.dart';
import 'package:messengersofpeace/Data/Model/quiz/question.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../Core/core.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Other/html_widget.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class TestResultsView extends StatefulWidget {
  const TestResultsView({super.key});
  @override
  State<TestResultsView> createState() => _TestResultsViewState();
}

class _TestResultsViewState extends State<TestResultsView> {
  final _loadKey = GlobalKey<FutureBuilderXState<void>>();
  TestResultsController get controller => Get.find<TestResultsController>();

  void _retry() {
    controller.retryRejectedSubmission();
    _loadKey.currentState?.refresh();
  }

  Widget _recovery() => SingleChildScrollView(
    padding: StyleX.paddingApp,
    child: Column(
      children: [
        TextX(
          controller.loadError?.toString() ?? 'Test result not confirmed yet',
        ),
        if (!controller.needsSubmissionRecovery)
          ButtonX(text: 'Try again', onTap: _retry, marginVertical: 16),
        ButtonX.second(
          text: 'Return to test information',
          onTap: controller.returnToTestInfo,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: controller.quiz.name),
      body: SafeArea(
        child: FutureBuilderX<void>(
          key: _loadKey,
          future: controller.getData,
          requestKey: (
            controller,
            controller.quizStartAttempt.attemptId,
            controller.quizId,
            TranslationX.getLanguageCode,
          ),
          loading: const TestResultsLoading(),
          child: (data) {
            if (!Get.isRegistered<TestResultsController>() ||
                !controller.ownsCurrentSession) {
              return const SizedBox.shrink();
            }
            if (controller.loadError != null ||
                !controller.hasConfirmedOutcome) {
              return _recovery();
            }
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Quiz image and name
                  Stack(
                    alignment: Alignment.center,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                            // The neutral empty arc is geometry only when
                            // the score denominator/data is unavailable.
                            percent: controller.scoreFraction ?? 0,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor:
                                controller.isSuccess
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                            center: TextX(
                              controller.scoreFraction == null
                                  ? '--'
                                  : "%${(controller.scoreFraction! * 100).toInt()}",
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
                                        ? Theme.of(context).colorScheme.primary
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
                                        ? Theme.of(context).colorScheme.primary
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
                                  "${controller.correctAnswers ?? '--'}",
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
                                  "${controller.wrongAnswers ?? '--'}",
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
                    _answerCard(
                      context,
                      controller.quizStartAttempt.questions[i],
                      i + 1,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _answerCard(BuildContext context, QuestionX question, int number) {
    final answer = controller.answerForQuestion(question);
    final selected = controller.selectedIndexForQuestion(question);
    final unavailable =
        answer == null ||
        !answer.hasSelectionDetails ||
        (answer.selectedAnswerIndex != null && selected == null);
    return ContainerX(
      key: ValueKey('result-question-${question.slot}'),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextX(
            '${"Question".tr} $number ${"of".tr} ${controller.quiz.totalQuestions}',
            style: TextStyleX.labelMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          HtmlWidgetX(html: question.text, textStyle: TextStyleX.titleMedium),
          const SizedBox(height: 16),
          if (unavailable || (selected != null && answer.right == null))
            const TextX('Answer details unavailable')
          else if (selected == null)
            const TextX('Not answered'),
          for (var index = 0; index < question.answers.length; index++)
            _answerOption(context, question, answer, selected, index),
        ],
      ),
    );
  }

  /// One answer option. The chosen answer is green when right and red when
  /// wrong; the other options keep the neutral colour.
  Widget _answerOption(
    BuildContext context,
    QuestionX question,
    AnswerX? answer,
    int? selected,
    int index,
  ) {
    final colors = Theme.of(context).colorScheme;
    // Only a graded, chosen option is coloured (right is null when ungraded)
    final isChosen = selected == index && answer?.right != null;
    final isRight = isChosen && answer!.right!;
    final success = context.isDarkMode ? ColorX.successDark : ColorX.success;
    return RadioButtonX<int>(
      key: ValueKey('result-choice-${question.slot}-$index'),
      value: index,
      groupValue: selected,
      color:
          isRight
              ? (context.isDarkMode
                  ? ColorX.successContainerDark
                  : ColorX.successContainer)
              : isChosen
              ? colors.errorContainer
              : colors.onInverseSurface,
      borderColor:
          isRight
              ? success
              : isChosen
              ? colors.error
              : null,
      onChanged: (_) {},
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: 12,
          top: 12,
          end: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HtmlWidgetX(
              html: question.answers[index],
              textStyle: TextStyleX.bodyMedium,
            ),
            if (isChosen)
              TextX(
                isRight ? 'Correct answer' : 'Incorrect answer',
                style: TextStyleX.bodyMedium,
                color: isRight ? success : colors.error,
              ).marginOnly(top: 4),
          ],
        ),
      ),
    ).fadeAnimation250;
  }
}
