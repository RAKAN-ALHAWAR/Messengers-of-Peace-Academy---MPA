import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import '../../../../../../../Config/config.dart';
import '../../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class ProfileImageSectionX extends GetView<EditProfileController> {
  const ProfileImageSectionX({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bottomSheetX(
          child: Column(
            children: [
              SizedBox(height: 20),
              ButtonX(
                text: "Gallery",
                onTap: controller.changeImage,
                iconData: IconX.photo,
              ).fadeAnimation100,
              ButtonX.gray(
                text: "Camera",
                onTap: () => controller.changeImage(isGallery: false),
                iconData: IconX.add_a_photo,
              ).fadeAnimation150,
            ],
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          /// Image
          GetBuilder<EditProfileController>(
            builder:
                (controller) =>
                    CircleAvatar(
                      radius: 49,
                      backgroundColor: Get.theme.cardColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: ImageNetworkX(
                          imageUrl:
                              controller.image != null
                                  ? controller.image!.path
                                  : controller.app.user.value.image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          isFile: controller.image != null,
                          failed: Center(child: Icon(Icons.person, size: 40)),
                        ),
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
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 14,
                  child: const Icon(IconX.edit, color: Colors.white, size: 17),
                ).fadeAnimation150,
          ),
        ],
      ),
    );
  }
}
