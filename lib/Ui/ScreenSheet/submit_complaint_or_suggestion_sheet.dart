import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../Ui/Widget/widget.dart';
import '../../Config/config.dart';
import '../../Core/core.dart';
import '../../Data/data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this bottom sheet }}~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Submit Complaint or Suggestion
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

submitComplaintOrSuggestionSheetX() {
  final AppControllerX app = Get.find();
  TextEditingController messageController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidate = AutovalidateMode.disabled;
  var isLoading = false.obs;
  var state = ButtonStateEX.normal.obs;
  return bottomSheetX(
    title: 'Submit Complaint or Suggestion',
    child: Obx(
      () => AbsorbPointer(
        absorbing: isLoading.value,
        child: Column(
          children: [
            Form(
              key: formKey,
              autovalidateMode: autovalidate,
              child: Column(
                children: [
                  TextFieldX(
                    controller: subjectController,
                    hint: 'Subject',
                    textInputAction: TextInputAction.next,
                    validate: ValidatorX.required,
                    color:
                        Theme.of(Get.context!).colorScheme.surfaceContainerLow,
                    margin: EdgeInsets.only(bottom: 12),
                  ).fadeAnimation200,
                  TextFieldX(
                    controller: messageController,
                    hint: 'Message text',
                    maxLines: 5,
                    minLines: 5,
                    textInputAction: TextInputAction.newline,
                    validate: ValidatorX.message,
                    color:
                        Theme.of(Get.context!).colorScheme.surfaceContainerLow,
                  ).fadeAnimation200,
                ],
              ),
            ),
            SizedBox(height: 16),
            ButtonStateX(
              state: state.value,
              text: 'Submit',
              onTap: () async {
                try {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    state.value = ButtonStateEX.loading;
                    var res = await DatabaseX.submitComplaintOrSuggestion(
                      name:
                          '${app.user.value.firstname} ${app.user.value.lastname}',
                      email: app.user.value.email,
                      subject: subjectController.text,
                      message: messageController.text,
                    );
                    Get.back();
                    if (res != null) {
                      ToastX.success(message: res);
                    }
                  } else {
                    autovalidate = AutovalidateMode.always;
                  }
                } catch (e) {
                  state.value = ButtonStateEX.failed;
                  ToastX.error(message: e);
                }
                isLoading.value = false;

                /// Reset button state
                Timer(
                  const Duration(
                    seconds: StyleX.returnButtonToNormalStateSecond,
                  ),
                  () {
                    state.value = ButtonStateEX.normal;
                  },
                );
              },
            ).fadeAnimation250,
          ],
        ),
      ),
    ),
  );
}
