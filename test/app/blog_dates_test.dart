import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/blog.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/ArticleDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/ArticleDetails/view/view.dart';

final article = BlogX(
  id: 'synthetic-article',
  subject: 'Synthetic article',
  summary: '<p>Fixture</p>',
  imageUrl: '',
  lang: 'en',
  createdAt: DateTime(2026, 7, 12, 12, 15),
);

class FixtureBlogController extends BlogController {
  @override
  Future<List<BlogX>> getData() async {
    blogs.assignAll([article]);
    return [article];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-blog-date-tests-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-blog-dates');
    await initializeDateFormatting();
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final locale in ['ar', 'en', 'es', 'fil']) {
    testWidgets('blog list and article use $locale dates with Latin digits', (
      tester,
    ) async {
      Get.testMode = true;
      final expected = (DateFormat('d MMMM . hh:mm a', locale)
        ..useNativeDigits = false).format(article.createdAt!);
      await tester.pumpWidget(
        GetMaterialApp(
          locale: Locale(locale),
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const BlogView(),
              binding: BindingsBuilder(() {
                Get.put<BlogController>(FixtureBlogController());
              }),
            ),
            GetPage(
              name: '/article',
              page: () => const ArticleDetailsView(),
              binding: BindingsBuilder(() {
                Get.put(ArticleDetailsController());
              }),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget);
      Get.toNamed('/article', arguments: article);
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget);
      expect(RegExp('[٠-٩]').hasMatch(expected), isFalse);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
