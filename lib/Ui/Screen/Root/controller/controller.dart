import 'package:get/get.dart';
import '../../../../Data/Constant/navbar_items.dart';
import '../../../../Data/Model/basic/root_page.dart';

class RootController extends GetxController {
  //============================================================================
  // Variables

  /// Pages
  late List<RootPageX> pages = navBarItems;

  /// Is more dynamic page
  RxBool isMoreDynamicPage = false.obs;

  /// Index page selected
  RxInt indexPageSelected = 0.obs;

  //============================================================================
  // Functions

  /// Check if the current page is the home page
  bool isHomePage() => indexPageSelected.value == 0;

  /// On item selected
  void onItemSelected(int index) => indexPageSelected.value = index;
}
