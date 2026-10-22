import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Data/Model/basic/data_source_param.dart';

void main() {
  test(
    'fallback and copying never silently opt out of authorization failures',
    () {
      final fallback = DataSourceParamX(
        fallbackResponse: const <String, Object>{},
      );
      expect(fallback.ignoreError, isTrue);
      expect(fallback.ignoreUnauthorized, isFalse);
      expect(fallback.copyWith(page: 2).ignoreUnauthorized, isFalse);
      final explicit = fallback.copyWith(ignoreUnauthorized: true);
      expect(explicit.ignoreUnauthorized, isTrue);
      expect(
        explicit.copyWith(ignoreUnauthorized: false).ignoreUnauthorized,
        isFalse,
      );
    },
  );
}
