import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/custom_field.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/EditProfile/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/EditProfile/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

UserX syntheticProfile({
  String prefix = '+963',
  String? phone,
  bool unknown = false,
}) => UserX(
  id: 'synthetic-user',
  username: 'synthetic',
  firstname: 'Test',
  lastname: 'User',
  email: 'test@example.invalid',
  lang: 'en',
  city: 'Damascus',
  image: '',
  points: 0,
  customfields:
      {
        'countrycode': prefix,
        'WhatsAppNumber': phone ?? '${prefix}944123456',
        'nationality': unknown ? 'Legacy Country' : 'Syria',
        'ulang': unknown ? 'Legacy Language' : 'Arabic',
        'gender': 'male',
        'Age': unknown ? 'Legacy Age' : '26-40 Yrs',
        'HearboutUs':
            unknown ? 'Legacy Referral' : ConstantX.howToFindUsList.first,
        'ifyesksastudy': unknown ? 'Legacy University' : '',
        'ksaunistudy': 'No',
      }.entries.map((e) => CustomField(name: e.key, value: e.value)).toList(),
);

class ProfileHarness {
  late Directory directory;
  late AppControllerX app;
  late EditProfileController controller;
  bool failReferences = false;
  bool emptyReferences = false;
  bool failPhoto = false;
  int referenceCalls = 0;
  int updateCalls = 0;
  int photoCalls = 0;
  int refreshCalls = 0;
  Map<String, String>? lastUpdate;
  Future<http.Response> Function()? onUpdate;
  Future<http.Response> Function()? onPhoto;
  Future<http.Response> Function()? onRefresh;
  Future<http.Response> Function()? onReference;

  Future<void> initialize() async {
    directory = await Directory.systemTemp.createTemp('mopa-profile-test-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  }

  Future<void> reset({UserX? user}) async {
    Get.testMode = true;
    await HiveX.box.clear();
    await HiveX.box.put('userid', 'synthetic-user');
    await HiveX.box.put('token', 'synthetic-token');
    app = Get.put(AppControllerX()..user = (user ?? syntheticProfile()).obs);
    controller = Get.put(EditProfileController());
    failReferences = emptyReferences = failPhoto = false;
    referenceCalls = updateCalls = photoCalls = refreshCalls = 0;
    lastUpdate = null;
    onUpdate = onPhoto = onRefresh = onReference = null;
  }

  void cleanUp() {
    ToastX.dismiss();
    Get.reset();
  }

  Future<void> close() async {
    await Hive.close();
    await directory.delete(recursive: true);
  }

  Future<void> mount(WidgetTester tester, {bool dark = false}) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        initialRoute: '/profile-base',
        getPages: [
          GetPage(
            name: '/profile-base',
            page: () => const Scaffold(body: Text('Profile base')),
          ),
          GetPage(name: '/profile-test', page: () => const EditProfileView()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed('/profile-test');
    await tester.pumpAndSettle();
  }

  String? function(String endpoint) =>
      Uri.parse(endpoint).queryParameters['wsfunction'];
  MockClient client() => MockClient((request) async {
    // Inspect stage/count or synthetic fields only. Never print Request/URL.
    final stage = request.url.queryParameters['wsfunction'];
    if ((request.headers['content-type'] ?? '').startsWith('multipart/')) {
      photoCalls++;
      return onPhoto?.call() ??
          http.Response(
            jsonEncode({
              'status': failPhoto ? 'error' : 'success',
              'message': failPhoto ? 'Synthetic photo failure' : 'Photo saved',
            }),
            200,
          );
    }
    if (stage == function(DBEndPointX.postUpdateUser)) {
      updateCalls++;
      lastUpdate = Map.of(request.bodyFields);
      return onUpdate?.call() ??
          http.Response('{"status":"success","message":"Profile saved"}', 200);
    }
    if (stage == function(DBEndPointX.postGetUser)) {
      refreshCalls++;
      return onRefresh?.call() ??
          http.Response(jsonEncode(app.user.value.toJson()), 200);
    }
    referenceCalls++;
    if (onReference != null) return onReference!();
    if (failReferences) {
      return http.Response(
        '{"status":"error","message":"Synthetic reference failure"}',
        503,
      );
    }
    if (emptyReferences) return http.Response('[]', 200);
    if (stage == function(DBEndPointX.postCountriesList)) {
      return http.Response('[{"code":"SA","name":"Saudi Arabia"}]', 200);
    }
    if (stage == function(DBEndPointX.postPhoneCodeCountriesList)) {
      return http.Response(
        '[{"code":"SA","name":"Saudi Arabia","dial_code":"+966"}]',
        200,
      );
    }
    if (stage == function(DBEndPointX.postNativeLanguages)) {
      return http.Response('[{"code":"en","name":"English"}]', 200);
    }
    throw StateError('Unexpected synthetic request stage');
  });
}
