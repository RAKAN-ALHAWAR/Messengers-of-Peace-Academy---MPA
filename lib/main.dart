import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Config/Route/route_list.dart';
import 'Config/Translation/translation.dart';
import 'Config/config.dart';
import 'Core/Logging/logging.dart';
import 'Core/core.dart';
import 'Data/data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// The project's starting point: everything is initialized here before the
/// project starts running.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void main() async {
  await LoggingX.safeZone(() async {
    // Ensures that the Flutter framework is properly initialized
    WidgetsFlutterBinding.ensureInitialized();

    // await Firebase.initializeApp();

    await ConfigX.init();
    await DataX.init();
    await CoreX.init();

    // Start the Flutter application
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //
  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      /// Remove mark debug
      debugShowCheckedModeBanner: false,

      /// Initialization of the main controllers
      initialBinding: BindingsBuilder(() {
        Get.put(AppControllerX(), permanent: true);
      }),

      /// Stop font enlargement according to the user's device font size
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },

      /// Routes
      getPages: RouteListX.routes,
      initialRoute: RouteNameX.loading,
      // ربط Firebase Analytics مع Navigation Observer
      // navigatorObservers: <NavigatorObserver>[observer],

      /// Settings GetX
      smartManagement: SmartManagement.full,
      useInheritedMediaQuery: true,

      /// App name with translate
      title: 'Meeting Platform'.tr,

      /// Translate App
      translations: TranslationX(),
      locale: TranslationX.getLocale,
      fallbackLocale: TranslationX.fallbackLocale,

      /// Themes
      themeMode: ThemeX.getTheme,
      theme: ThemeX.light,
      darkTheme: ThemeX.dark,
    );
  }
}
