import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../../../Config/config.dart';
import '../../../../../../Ui/Widget/widget.dart';
import '../../controller/controller.dart';

class ProfileImageSectionX extends GetView<CompleteAccountInfoController> {
  const ProfileImageSectionX({super.key});

  @override
  Widget build(BuildContext context) {
    /// Profile image section
    return GestureDetector(
      onTap: () {
        /// Open bottom sheet to select image from gallery or camera
        bottomSheetX(
          child: Column(
            children: [
              /// Gallery button
              ButtonX(
                text: "Gallery",
                onTap: controller.changeImage,
                iconData: IconX.photo,
              ).fadeAnimation100.marginOnly(top: 20),

              /// Camera button
              ButtonX.gray(
                text: "Camera",
                onTap: () => controller.changeImage(isGallery: false),
                iconData: IconX.add_a_photo,
              ).fadeAnimation150,
            ],
          ),
        );
      },

      /// Profile image
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          /// Profile image
          GetBuilder<CompleteAccountInfoController>(
            builder:
                (controller) =>
                    ImageNetworkX(
                      imageUrl: controller.image?.path ?? "",
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      radius: 100,
                      isFile: controller.image != null,
                      failed: Container(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: Center(child: Icon(Icons.person, size: 40)),
                      ),
                    ).fadeAnimation150,
          ),

          /// Upload Icon
          Positioned.directional(
            textDirection: Directionality.of(context),
            start: 4.0,
            bottom: 0.0,
            child:
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(IconX.edit, color: Colors.white, size: 17),
                ).fadeAnimation150,
          ),
        ],
      ),
    );
  }
}
