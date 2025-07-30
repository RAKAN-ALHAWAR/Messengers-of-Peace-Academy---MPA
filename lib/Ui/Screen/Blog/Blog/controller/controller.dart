import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Config/config.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Data/Model/blog.dart';
import '../../../../../Data/data.dart';

class BlogController extends GetxController {
  //============================================================================
  // Functions

  /// Get blogs from database
  Future<List<BlogX>> getData() async {
    return await DatabaseX.getBlogs(
      lang: TranslationX.getLanguageCode.toLowerCase(),
    );
  }

  /// Navigate to article details
  void onArticleDetails(BlogX blog) {
    Get.toNamed(RouteNameX.articleDetails, arguments: blog);
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }
}
