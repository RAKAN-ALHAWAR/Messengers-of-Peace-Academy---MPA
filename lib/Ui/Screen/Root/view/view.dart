import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Widget/widget.dart';
import '../controller/controller.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// for don't move navbar when open keyboard
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Obx(
        () => Scaffold(
          /// App bar
          appBar:
              /// If the current page is the home page, don't show app bar
              controller.isHomePage()
                  ? null
                  : AppBarX(
                    key: Key(
                      controller
                          .pages[controller.indexPageSelected.value]
                          .label,
                    ),
                    title:
                        controller
                            .pages[controller.indexPageSelected.value]
                            .label,
                    isBack: false,
                  ),

          /// Pages content
          body: controller.pages[controller.indexPageSelected.value].view,

          /// Nav bar
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.indexPageSelected.value,
            onDestinationSelected: controller.onItemSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations:
                /// Build nav bar destinations
                controller.pages.map((page) {
                  return NavigationDestination(
                    icon: page.icon,
                    label: page.label.tr,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
