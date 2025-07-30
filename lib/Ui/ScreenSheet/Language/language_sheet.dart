import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../Config/Translation/translation.dart';
import '../../../../Data/data.dart';
import '../../../Config/config.dart';
import '../../../Ui/Widget/widget.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this bottom sheet }}~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Choose one of the languages available for the application
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

languageSheetX(Function(String val) changeLanguage) {
  return bottomSheetX(
    title: 'App Language',
    child: Column(
      /// Fetch available languages
      children:
          TranslationX.languages.map((Map<String, String> language) {
            return GestureDetector(
              onTap: () async {
                await changeLanguage(language[NameX.code] ?? '');
              },
              child:
                  ContainerX(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    color:
                        Theme.of(Get.context!).colorScheme.surfaceContainerLow,
                    child: Row(
                      children: [
                        TextX(
                          language[NameX.name] ?? '',
                          style: TextStyleX.bodyLarge,
                        ).marginSymmetric(horizontal: 16),
                        Spacer(),
                        RadioButtonX(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          isJustBox: true,
                          groupValue: TranslationX.getLanguageCode,
                          value: language[NameX.code],
                          onChanged: (_) async {
                            await changeLanguage(language[NameX.code] ?? '');
                          },
                        ),
                      ],
                    ),
                  ).marginOnly(bottom: 12).fadeAnimation200,
            );
          }).toList(),
    ),
  );
}
