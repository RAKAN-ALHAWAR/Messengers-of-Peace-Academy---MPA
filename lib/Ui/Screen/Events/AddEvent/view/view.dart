import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../../Core/core.dart';
import '../../../../Widget/Basic/Input/text_field_time.dart';
import '../controller/controller.dart';

class AddEventView extends GetView<AddEventController> {
  const AddEventView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Add event view
    return Scaffold(
      /// App bar
      appBar: AppBarX(title: 'Add new event'),

      /// Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: StyleX.paddingApp,
          child: Obx(
            /// Lock screen when loading
            () => AbsorbPointer(
              absorbing: controller.isLoading.value,
              child: Form(
                key: controller.formKey,
                autovalidateMode: controller.autovalidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Event title input
                    TextFieldX(
                      controller: controller.title,
                      hint: "Event title",
                      validate: ValidatorX.eventTitle,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      margin: EdgeInsets.only(bottom: 12),
                    ).fadeAnimation150,

                    /// Event description input
                    TextFieldX(
                      controller: controller.description,
                      hint: "Event Details",
                      validate: ValidatorX.description,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      minLines: 5,
                      margin: EdgeInsets.only(bottom: 12),
                    ).fadeAnimation150,

                    /// Event location input
                    TextFieldX(
                      controller: controller.location,
                      hint: "Location",
                      validate: ValidatorX.location,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      margin: EdgeInsets.only(bottom: 16),
                    ).fadeAnimation150,

                    /// Event start and end title
                    TextX(
                      "Event start and end",
                      style: TextStyleX.labelLarge,
                    ).fadeAnimation200,
                    SizedBox(height: 12),

                    /// Event start and end date and time input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Event start date and time input
                        Flexible(
                          flex: 3,
                          child: TextFieldDateX(
                            controller: controller.dateStart,
                            hint: "Date",
                            margin: EdgeInsets.zero,
                            icon: IconX.today,
                            format: 'yyyy/MM/dd',
                            onChange: controller.onChangeDateStart,
                            validate: ValidatorX.date,
                          ),
                        ),
                        SizedBox(width: 8),

                        /// Event start time input
                        Flexible(
                          flex: 2,
                          child: TextFieldTimeX(
                            controller: controller.timeStart,
                            hint: "Time",
                            margin: EdgeInsets.zero,
                            icon: IconX.schedule,
                            onChange: controller.onChangeTimeStart,
                            validate: ValidatorX.required,
                          ),
                        ),
                      ],
                    ).fadeAnimation200,

                    /// Spacer
                    SizedBox(height: 8),

                    /// Event end date and time input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Event end date input
                        Flexible(
                          flex: 3,
                          child: TextFieldDateX(
                            controller: controller.dateEnd,
                            hint: "Date",
                            margin: EdgeInsets.zero,
                            icon: IconX.today,
                            format: 'yyyy/MM/dd',
                            onChange: controller.onChangeDateEnd,
                            validate: ValidatorX.date,
                          ),
                        ),

                        /// Spacer
                        SizedBox(width: 8),

                        /// Event end time input
                        Flexible(
                          flex: 2,
                          child: TextFieldTimeX(
                            controller: controller.timeEnd,
                            hint: "Time",
                            margin: EdgeInsets.zero,
                            icon: IconX.schedule,
                            onChange: controller.onChangeTimeEnd,
                            validate: ValidatorX.required,
                          ),
                        ),
                      ],
                    ).fadeAnimation200,

                    /// Spacer
                    SizedBox(height: 12),

                    /// Event repeat switch
                    SwitchX(
                      value: controller.isRepeated.value,
                      label: "Repeat this event weekly",
                      onChange: (value) => controller.isRepeated.value = value,
                    ).fadeAnimation250,

                    /// Event repeat count input
                    if (controller.isRepeated.value)
                      TextFieldX(
                        controller: controller.repeatCount,
                        hint: "Number of weeks to repeat the event",
                        validate: ValidatorX.repeatCount,
                        textInputAction: TextInputAction.done,
                        textInputType: TextInputType.number,
                        margin: EdgeInsets.only(top: 12),
                      ).fadeAnimation250,

                    /// Spacer
                    SizedBox(height: 24),

                    /// Save and cancel buttons
                    Row(
                      children: [
                        /// save button
                        Flexible(
                          child: ButtonStateX(
                            state: controller.buttonState.value,
                            text: "Save",
                            onTap: controller.onAddEvent,
                          ),
                        ),

                        /// Spacer
                        SizedBox(width: 8),

                        /// Cancel button
                        Flexible(
                          child: ButtonX.second(
                            text: "Cancel",
                            onTap: Get.back,
                          ),
                        ),
                      ],
                    ).fadeAnimation300,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
