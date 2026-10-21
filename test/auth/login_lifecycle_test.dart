import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/auth/otp.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/Login/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/SignUp/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'session_lifecycle_test.dart' show syntheticUser;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-login-lifecycle-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.removeAll();
    app = Get.put(AppControllerX(), permanent: true);
  });
  tearDown(() {
    ToastX.dismiss();
    Get.delete<LoginController>(force: true);
    Get.delete<SignUpController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<LoginController> mount(WidgetTester tester) async {
    final controller = Get.put(LoginController());
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/login-test',
        getPages: [
          GetPage(
            name: '/login-test',
            page:
                () => Scaffold(
                  body: Form(key: controller.formKey, child: const SizedBox()),
                ),
          ),
          GetPage(
            name: RouteNameX.root,
            page: () => const Scaffold(body: Text('Root destination')),
          ),
          GetPage(
            name: RouteNameX.otp,
            page: () => const Scaffold(body: Text('OTP destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    controller.email.text = 'first@example.invalid';
    controller.password.text = 'Synthetic-password-1';
    return controller;
  }

  for (final malformed in ['token', 'userid']) {
    testWidgets(
      'login missing $malformed makes no profile request or session',
      (tester) async {
        var count = 0;
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            await controller.onLogin();
            await tester.pump();
            expect(count, 1);
            expect(app.isLogin.value, isFalse);
            expect(LocalDataX.userid, isEmpty);
            expect(LocalDataX.token, isEmpty);
            expect(find.text('Root destination'), findsNothing);
            await tester.pump(const Duration(seconds: 5));
          },
          () => MockClient((_) async {
            count++;
            return http.Response(
              jsonEncode({
                'userid': malformed == 'userid' ? '' : 'synthetic-A',
                'token': malformed == 'token' ? '' : 'synthetic-token-A',
              }),
              200,
            );
          }),
        );
      },
    );
  }

  for (final abandon in ['close', 'route', 'session', 'same-token']) {
    testWidgets(
      'pending login ignores abandoned $abandon and rejects duplicates',
      (tester) async {
        var count = 0;
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            final pending = controller.onLogin();
            await tester.pump();
            await controller.onLogin();
            expect(count, 1);
            if (abandon == 'close') {
              Get.delete<LoginController>(force: true);
            } else if (abandon == 'route') {
              Get.toNamed(RouteNameX.otp);
              await tester.pumpAndSettle();
            } else {
              await tester.runAsync(() async {
                await LocalDataX.put(
                  LocalKeyX.token,
                  abandon == 'session' ? 'synthetic-token-B' : '',
                );
              });
            }
            response.complete(
              http.Response(
                '{"userid":"synthetic-A","token":"synthetic-token-A"}',
                200,
              ),
            );
            await pending;
            await tester.pump();
            expect(count, 1);
            expect(LocalDataX.userid, isEmpty);
            expect(app.isLogin.value, isFalse);
            expect(find.text('Root destination'), findsNothing);
          },
          () => MockClient((_) {
            count++;
            return response.future;
          }),
        );
      },
    );
  }

  testWidgets(
    'profile mismatch clears provisional credentials and permits retry',
    (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          final pending = tester.runAsync(controller.onLogin);
          await pending;
          await tester.pump();
          expect(count, 2);
          expect(LocalDataX.userid, isEmpty);
          expect(LocalDataX.token, isEmpty);
          expect(app.isLogin.value, isFalse);
          expect(controller.isLoading.value, isFalse);
          expect(controller.buttonStateLogin.value, ButtonStateEX.failed);
          expect(find.text('Root destination'), findsNothing);
          await tester.pump(const Duration(seconds: 5));
        },
        () => MockClient((_) async {
          count++;
          return http.Response(
            count == 1
                ? '{"userid":"synthetic-A","token":"synthetic-token-A"}'
                : jsonEncode(syntheticUser('synthetic-B')),
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'unconfirmed login without authoritative ID stays actionable and makes no OTP request',
    (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.onLogin();
          await tester.pump();
          expect(count, 1);
          expect(find.text('OTP destination'), findsNothing);
          expect(
            find.text(
              'Your account still needs verification. Please contact support to recover verification access.',
            ),
            findsOneWidget,
          );
          expect(LocalDataX.userid, isEmpty);
          await tester.pump(const Duration(seconds: 5));
        },
        () => MockClient((_) async {
          count++;
          return http.Response('{"errorcode":"usernotconfirmed"}', 200);
        }),
      );
    },
  );

  testWidgets(
    'unconfirmed login carries only known userid and original submitted email',
    (tester) async {
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        final pending = controller.onLogin();
        await tester.pump();
        controller.email.text = 'changed@example.invalid';
        response.complete(
          http.Response(
            '{"errorcode":"usernotconfirmed","userid":"synthetic-A"}',
            200,
          ),
        );
        await pending;
        await tester.pumpAndSettle();
        expect(find.text('OTP destination'), findsOneWidget);
        final otp = Get.arguments as OtpX;
        expect(otp.userid, 'synthetic-A');
        expect(otp.email, 'first@example.invalid');
      }, () => MockClient((_) => response.future));
    },
  );

  testWidgets(
    'successful login verifies profile then navigates with one submission',
    (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          final pending = tester.runAsync(controller.onLogin);
          await tester.pump();
          await pending;
          await tester.pumpAndSettle();
          expect(count, 2);
          expect(app.isLogin.value, isTrue);
          expect(app.user.value.id, 'synthetic-A');
          expect(find.text('Root destination'), findsOneWidget);
        },
        () => MockClient((_) async {
          count++;
          return http.Response(
            count == 1
                ? '{"userid":"synthetic-A","token":"synthetic-token-A"}'
                : jsonEncode(syntheticUser('synthetic-A')),
            200,
          );
        }),
      );
    },
  );

  for (final abandon in [false, true]) {
    testWidgets(
      'signup snapshots email and ${abandon ? 'ignores disposal' : 'passes authoritative ID'}',
      (tester) async {
        var count = 0;
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = Get.put(SignUpController());
            await tester.pumpWidget(
              GetMaterialApp(
                initialRoute: '/signup-test',
                getPages: [
                  GetPage(
                    name: '/signup-test',
                    page:
                        () => Scaffold(
                          body: Form(
                            key: controller.formKey,
                            child: const SizedBox(),
                          ),
                        ),
                  ),
                  GetPage(
                    name: RouteNameX.otp,
                    page: () => const Scaffold(body: Text('OTP destination')),
                  ),
                ],
              ),
            );
            await tester.pumpAndSettle();
            controller.email.text = 'first@example.invalid';
            controller.verificationMethod = 'Email';
            final pending = controller.onSignUp();
            await tester.pump();
            await controller.onSignUp();
            expect(count, 1);
            controller.email.text = 'changed@example.invalid';
            if (abandon) Get.delete<SignUpController>(force: true);
            response.complete(http.Response('{"userid":"synthetic-A"}', 200));
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));
            await pending;
            await tester.pumpAndSettle();
            expect(
              find.text('OTP destination'),
              abandon ? findsNothing : findsOneWidget,
            );
            if (!abandon) {
              expect((Get.arguments as OtpX).email, 'first@example.invalid');
              expect((Get.arguments as OtpX).userid, 'synthetic-A');
            }
          },
          () => MockClient((_) {
            count++;
            return response.future;
          }),
        );
      },
    );
  }
  for (final abandon in ['closed', 'replacement', 'profile-error']) {
    testWidgets(
      'provisional login profile $abandon cannot leave a partial session',
      (tester) async {
        var count = 0;
        late Completer<http.Response> profile;
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            await tester.runAsync(() async {
              profile = Completer<http.Response>();
              final pending = controller.onLogin();
              while (count < 2) {
                await Future<void>.delayed(const Duration(milliseconds: 1));
              }
              if (abandon == 'closed') {
                Get.delete<LoginController>(force: true);
              }
              if (abandon == 'replacement') {
                await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
                await LocalDataX.put(LocalKeyX.token, 'synthetic-token-B');
                app.isLogin.value = true;
              }
              profile.complete(
                http.Response(
                  abandon == 'profile-error'
                      ? '{"status":"error","message":"Synthetic profile failure"}'
                      : jsonEncode(syntheticUser('synthetic-A')),
                  200,
                ),
              );
              await pending;
            });
            await tester.pump();
            expect(count, 2);
            expect(
              LocalDataX.userid,
              abandon == 'replacement' ? 'synthetic-B' : '',
            );
            expect(app.isLogin.value, abandon == 'replacement');
            expect(find.text('Root destination'), findsNothing);
            await tester.pump(const Duration(seconds: 5));
          },
          () => MockClient((_) {
            count++;
            return count == 1
                ? Future.value(
                  http.Response(
                    '{"userid":"synthetic-A","token":"synthetic-token-A"}',
                    200,
                  ),
                )
                : profile.future;
          }),
        );
      },
    );
  }

  testWidgets('verification return leaves login usable', (tester) async {
    await http.runWithClient(
      () async {
        final controller = await mount(tester);
        await controller.onLogin();
        await tester.pumpAndSettle();
        Get.back();
        await tester.pumpAndSettle();
        expect(controller.isLoading.value, isFalse);
        expect(controller.buttonStateLogin.value, ButtonStateEX.normal);
      },
      () => MockClient(
        (_) async => http.Response(
          '{"errorcode":"usernotconfirmed","userid":"synthetic-A"}',
          200,
        ),
      ),
    );
  });
}
