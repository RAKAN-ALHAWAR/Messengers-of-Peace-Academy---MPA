import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/Model/blog.dart';

Map<String, dynamic> article(Object? tag) => {
  'id': 'synthetic-article',
  'subject': 'Synthetic article',
  'summary': '<p>Synthetic content</p>',
  'attachmentfiles': [],
  'tags': tag,
};

void main() {
  test(
    'absent, short and malformed optional tags do not drop valid articles',
    () {
      final inputs = <Object?>[
        null,
        [],
        [
          {'name': null},
        ],
        [
          {'name': ''},
        ],
        [
          {'name': 'a'},
        ],
        [
          {'name': '😀'},
        ],
        ['invalid optional tag'],
        'invalid optional tags',
      ];
      final parsed = ModelUtilX.generateItems(
        inputs.map(article).toList(),
        BlogX.fromJson,
      );
      expect(parsed.length, inputs.length);
      for (final blog in parsed) {
        expect(blog.id, 'synthetic-article');
        expect(blog.subject, 'Synthetic article');
        expect(blog.summary, '<p>Synthetic content</p>');
        expect(blog.lang, 'en');
      }
    },
  );

  test('normal language prefixes retain case normalization', () {
    expect(
      BlogX.fromJson(
        article([
          {'name': 'ES-language'},
        ]),
      ).lang,
      'es',
    );
    expect(
      BlogX.fromJson(
        article([
          {'name': 'Arabic'},
        ]),
      ).lang,
      'ar',
    );
  });

  test('Unicode prefixes retain complete code points', () {
    expect(
      BlogX.fromJson(
        article([
          {'name': '中文文章'},
        ]),
      ).lang,
      '中文',
    );
    expect(
      BlogX.fromJson(
        article([
          {'name': '😀en'},
        ]),
      ).lang,
      '😀e',
    );
  });

  test('tag tolerance does not supply a missing required article ID', () {
    final malformed = article([
      {'name': 'a'},
    ])..remove('id');
    expect(() => BlogX.fromJson(malformed), throwsException);
  });
}
