import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Enum/event_option.dart';
import '../../../../Widget/Basic/Input/text_field_time.dart';
import '../controller/controller.dart';

class EditEventView extends GetView<EditEventController> {
  const EditEventView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Edit event'),
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
                    /// Title input
                    TextFieldX(
                      controller: controller.title,
                      hint: "Event title",
                      validate: ValidatorX.eventTitle,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      margin: EdgeInsets.only(bottom: 12),
                    ).fadeAnimation150,

                    /// Description input
                    TextFieldX(
                      controller: controller.description,
                      hint: "Event Details",
                      validate: ValidatorX.description,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      minLines: 5,
                      margin: EdgeInsets.only(bottom: 12),
                    ).fadeAnimation150,

                    /// Location input
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

                    /// Date and time start and end
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Start date input
                        Flexible(
                          flex: 3,
                          child: TextFieldDateX(
                            controller: controller.dateStart,
                            hint: "Date",
                            margin: EdgeInsets.zero,
                            initialDate: controller.dateTimeStart,
                            icon: IconX.today,
                            format: 'yyyy/MM/dd',
                            onChange: controller.onChangeDateStart,
                            validate: ValidatorX.date,
                          ),
                        ),

                        /// Spacer
                        SizedBox(width: 8),

                        /// Start time input
                        Flexible(
                          flex: 2,
                          child: TextFieldTimeX(
                            controller: controller.timeStart,
                            hint: "Time",
                            margin: EdgeInsets.zero,
                            initialTime: controller.timeOfDayStart,
                            icon: IconX.schedule,
                            onChange: controller.onChangeTimeStart,
                            validate: ValidatorX.required,
                          ),
                        ),
                      ],
                    ).fadeAnimation200,

                    /// Spacer
                    SizedBox(height: 8),

                    /// Date and time start and end
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// End date input
                        Flexible(
                          flex: 3,
                          child: TextFieldDateX(
                            controller: controller.dateEnd,
                            hint: "Date",
                            margin: EdgeInsets.zero,
                            initialDate: controller.dateTimeEnd,
                            icon: IconX.today,
                            format: 'yyyy/MM/dd',
                            onChange: controller.onChangeDateEnd,
                            validate: ValidatorX.date,
                          ),
                        ),

                        /// Spacer
                        SizedBox(width: 8),

                        /// End time input
                        Flexible(
                          flex: 2,
                          child: TextFieldTimeX(
                            controller: controller.timeEnd,
                            hint: "Time",
                            margin: EdgeInsets.zero,
                            initialTime: controller.timeOfDayEnd,
                            icon: IconX.schedule,
                            onChange: controller.onChangeTimeEnd,
                            validate: ValidatorX.required,
                          ),
                        ),
                      ],
                    ).fadeAnimation250,

                    /// Spacer
                    SizedBox(height: 12),

                    /// Repeat switch
                    SwitchX(
                      value: controller.isRepeated.value,
                      onChange: (value) {
                        controller.isRepeated.value = value;
                      },
                      label: "Repeat this event weekly",
                    ).fadeAnimation250,

                    /// Repeat count input
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
                    SizedBox(height: 16),

                    /// Apply changes label
                    TextX(
                      "Apply changes",
                      style: TextStyleX.labelLarge,
                    ).fadeAnimation250,
                    SizedBox(height: 8),

                    /// Apply changes radio "Only"
                    RadioButtonX<EventOptionEX>(
                      label: "For this event only",
                      groupValue: controller.editOption.value,
                      value: EventOptionEX.single,
                      onChanged: controller.onChangeEditOption,
                      margin: EdgeInsets.only(bottom: 8),
                    ).fadeAnimation300,

                    /// Apply changes radio "Future"
                    RadioButtonX<EventOptionEX>(
                      label: "For future events",
                      groupValue: controller.editOption.value,
                      value: EventOptionEX.future,
                      onChanged: controller.onChangeEditOption,
                      margin: EdgeInsets.only(bottom: 8),
                    ).fadeAnimation300,

                    /// Apply changes radio "All"
                    RadioButtonX<EventOptionEX>(
                      label: "All events",
                      groupValue: controller.editOption.value,
                      value: EventOptionEX.all,
                      onChanged: controller.onChangeEditOption,
                      margin: EdgeInsets.only(bottom: 24),
                    ).fadeAnimation300,

                    /// Save and cancel buttons
                    Row(
                      children: [
                        /// Save button
                        Flexible(
                          child: ButtonStateX(
                            state: controller.buttonState.value,
                            text: "Save",
                            onTap: controller.onEditEvent,
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
                    ).fadeAnimation350,
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
