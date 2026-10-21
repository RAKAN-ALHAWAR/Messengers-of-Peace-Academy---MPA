import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-quiz-ack-test-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HiveX.box.put('userid', 'synthetic-user');
    await HiveX.box.put('token', 'synthetic-token');
    HttpX.init();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  test(
    'submitQuiz rejects explicit status:error in a successful HTTP response',
    () async {
      var requests = 0;
      await http.runWithClient(
        () async {
          await expectLater(
            DatabaseX.submitQuiz(attemptId: 'synthetic-attempt'),
            throwsA(isA<ErrorX>()),
          );
          expect(requests, 1);
        },
        () => MockClient((_) async {
          requests++;
          return http.Response(
            jsonEncode({'status': 'error', 'message': 'Synthetic rejection'}),
            200,
          );
        }),
      );
    },
  );
}
