import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/html_widget.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../controller/controller.dart';

class TestQuestionsView extends GetView<TestQuestionsController> {
  const TestQuestionsView({super.key});
  Future<void> _onWillPop(BuildContext context) async {
    if (!controller.ownsCurrentSession) return;
    final shouldExit = await AlertDialogX.okAndCancel(
      title: 'تأكيد الخروج',
      message: 'هل أنت متأكد أنك تريد الخروج من الصفحة؟',
      onOk: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (shouldExit == true && controller.ownsCurrentSession) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onWillPop(context);
      },
      child: Scaffold(
        appBar: AppBarX(
          title: controller.quiz.name,
          onBack: () => _onWillPop(context),
        ),
        body: FutureBuilderX<void>(
          future: controller.getData,
          requestKey: (
            controller,
            controller.quizId,
            TranslationX.getLanguageCode,
          ),
          child: (_) {
            if (!Get.isRegistered<TestQuestionsController>() ||
                !controller.ownsCurrentSession) {
              return const SizedBox.shrink();
            }
            return Obx(() {
              if (controller.needsRecovery) {
                return Padding(
                  padding: StyleX.paddingApp,
                  child: Column(
                    children: [
                      TextX(
                        controller.answerError.value ??
                            'Your existing test attempt needs recovery. Return to test information.',
                      ),
                      ButtonX(
                        text: 'Return to test information',
                        onTap: controller.returnToTestInfo,
                        marginVertical: 16,
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: StyleX.paddingApp,
                child: Obx(
                  () => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextX(
                            "${"Question".tr} ${controller.currentQuestionIndex + 1} ${"of".tr} ${controller.quiz.totalQuestions}",
                            style: TextStyleX.labelLarge,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          ContainerX(
                            radius: 100,
                            color: ColorX.yellow.shade700,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconX.alarm,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                TextX(
                                  controller.timeRemaining.value,
                                  style: TextStyleX.labelLarge,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).fadeAnimation150,
                      SizedBox(height: 15),
                      ContainerX(
                        key: Key(
                          "question_card_${controller.currentQuestionIndex}",
                        ),
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HtmlWidgetX(
                              key: Key(
                                "question_text_${controller.currentQuestionIndex}",
                              ),
                              html:
                                  controller
                                      .quizStartAttempt
                                      .questions[controller
                                          .currentQuestionIndex]
                                      .text,
                              textStyle: TextStyleX.titleMedium,
                            ).fadeAnimation200,
                            SizedBox(height: 16),
                            for (
                              var optionIndex = 0;
                              optionIndex <
                                  controller
                                      .quizStartAttempt
                                      .questions[controller
                                          .currentQuestionIndex]
                                      .answers
                                      .length;
                              optionIndex++
                            )
                              RadioButtonX<int>(
                                key: ValueKey(
                                  "question_option_${controller.currentQuestionIndex}_$optionIndex",
                                ),
                                value: optionIndex,
                                groupValue: controller.selectedAnswer.value,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onInverseSurface,
                                onChanged:
                                    (value) => controller.onChangeAnswer(value),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    bottom: 12,
                                    top: 12,
                                    end: 12,
                                  ),
                                  child: HtmlWidgetX(
                                    html:
                                        controller
                                            .quizStartAttempt
                                            .questions[controller
                                                .currentQuestionIndex]
                                            .answers[optionIndex],
                                    textStyle: TextStyleX.bodyMedium,
                                  ),
                                ),
                              ).fadeAnimation250,
                          ],
                        ),
                      ).fadeAnimation200,
                      Spacer(),
                      if (controller.answerError.value != null)
                        TextX(
                          controller.answerError.value!,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ButtonStateX(
                        disabled: controller.selectedAnswer.value == null,
                        state: controller.buttonState.value,
                        text:
                            controller.currentQuestionIndex ==
                                    controller
                                            .quizStartAttempt
                                            .questions
                                            .length -
                                        1
                                ? "Submitting answers"
                                : "Next question",
                        onTap: controller.onNextQuestion,
                      ).marginOnly(bottom: 16).fadeAnimation200,
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
