part of '../http.dart';

/// ## A utility class for handling HTTP responses and parsing them based on status codes and content types.
///
/// This class provides methods to process HTTP responses by interpreting their status codes and content types.
/// It handles various scenarios such as informational responses, successful responses, and error responses.
///
/// - **Informational responses**: For status codes in the 1xx range, it returns a fallback response or nall.
/// - **Successful responses**: For status codes in the 2xx range, it parses and returns the response body.
/// - **Error responses**: For status codes outside the 2xx range, it determines whether to return a fallback response or throw an error based on provided flags.
///
/// ### Example usage:
/// ```dart
/// final response = await http.get(Uri.parse('https://example.com/data'));
/// final result = await HttpResponseX.call(response, 'Fallback response', false);
/// print(result);
/// ```
/// This will print the parsed response based on the status code and content type, or the fallback response if an error occurs.
///
/// ------------------------------------------------------------------------------
///
/// ## فئة مساعدة لمعالجة استجابات HTTP وتحليلها بناءً على رموز الحالة وأنواع المحتوى.
///
/// توفر هذه الفئة طرقًا لمعالجة استجابات HTTP من خلال تفسير رموز الحالة وأنواع المحتوى الخاصة بها.
/// تتعامل مع سيناريوهات مختلفة مثل الاستجابات المعلوماتية، الاستجابات الناجحة، واستجابات الأخطاء.
///
/// - **الاستجابات المعلوماتية**: بالنسبة لرموز الحالة في النطاق 1xx، تعيد استجابة احتياطية أو فارغة.
/// - **الاستجابات الناجحة**: بالنسبة لرموز الحالة في النطاق 2xx، تقوم بتحليل وإرجاع جسم الاستجابة.
/// - **استجابات الأخطاء**: بالنسبة لرموز الحالة خارج النطاق 2xx، تحدد ما إذا كانت ستعيد استجابة احتياطية أو ترمي خطأ بناءً على الأعلام المقدمة.
///
/// ### مثال على الاستخدام:
/// ```dart
/// final response = await http.get(Uri.parse('https://example.com/data'));
/// final result = await HttpResponseX.call(response, 'استجابة احتياطية', false);
/// print(result);
/// ```
/// سيطبع هذا النتيجة المحللة بناءً على رمز الحالة ونوع المحتوى، أو الاستجابة الاحتياطية إذا حدث خطأ.
class HttpResponseX {
  /// ## Processes HTTP responses based on their status codes and content.
  ///
  /// This function interprets HTTP responses by evaluating the status code and content type.
  ///
  /// - For informational responses (status codes in the 1xx range), it returns a fallback response or null.
  /// - For successful responses (status codes in the 2xx range), it parses and returns the response body.
  /// - For error responses (status codes outside the 2xx range), it decides whether to return a fallback response or throw an error based on the provided flags.
  ///
  /// ### Example:
  ///
  /// For a successful JSON response:
  /// ```dart
  /// {
  ///   'id': 123,
  ///   'name': 'John Doe',
  ///   'email': 'john.doe@example.com'
  /// }
  /// ```
  ///
  /// For a fallback response:
  /// ```dart
  /// fallbackResponse
  /// ```
  ///
  /// For an empty body or error with ignoreError flag set to true:
  /// ```dart
  /// null
  /// ```
  ///
  /// For a Text response:
  /// ```dart
  /// "Database connection was successful."
  /// ```
  /// -----------------------------------------------------------------------
  /// ## تقوم هذه الوظيفة بمعالجة استجابات HTTP بناءً على رمز الحالة ونوع المحتوى.
  ///
  /// - بالنسبة للاستجابات المعلوماتية (رموز الحالة في النطاق 1xx)، يتم إرجاع استجابة احتياطية أو فارغة.
  /// - بالنسبة للاستجابات الناجحة (رموز الحالة في النطاق 2xx)، يتم تحليل جسم الاستجابة وإرجاعه .
  /// - بالنسبة للاستجابات الخطأ (رموز الحالة خارج النطاق 2xx)، تقرر الوظيفة ما إذا كانت ستعيد استجابة احتياطية أو ترمي خطأ بناءً على الأعلام المقدمة.
  ///
  /// ### مثال:
  ///
  /// بالنسبة لاستجابة JSON ناجحة:
  /// ```dart
  /// {
  ///   'id': 123,
  ///   'name': 'John Doe',
  ///   'email': 'john.doe@example.com'
  /// }
  /// ```
  ///
  /// بالنسبة لاستجابة احتياطية:
  /// ```dart
  /// fallbackResponse
  /// ```
  ///
  /// بالنسبة لجسم فارغ أو خطأ مع تعيين علامة ignoreError إلى true:
  /// ```dart
  /// null
  /// ```
  ///
  /// بالنسبة لاستجابة Text:
  /// ```dart
  /// "Database connection was successful."
  /// ```
  static Future<T?> call<T>(
    http.Response response, [
    T? fallbackResponse,
    bool ignoreUnauthorized = false,
  ]) async {
    // Informational response
    // If the status code is in the category 1xx (100-199), an empty object is returned.
    // This means that the request is being processed and the current code is instructional or indicative.
    // استجابة معلوماتية
    // إذا كان رمز الحالة في الفئة 1xx (100-199)، يتم إرجاع كائن فارغ.
    // هذا يعني أن الطلب قيد المعالجة والرمز الحالي تعليمي أو إشاري.
    if (response.statusCode >= 100 && response.statusCode < 200) {
      return fallbackResponse;
    }

    // If the response body is empty, return an null.
    // إذا كان جسم الاستجابة فارغًا، يتم إرجاع قيمة فارغة.
    if (response.body.isEmpty) {
      return null;
    }

    dynamic responseBody;
    // Attempt to parse response body as JSON.
    // محاولة لتحليل جسم الاستجابة كـ JSON.
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = response.body;
    }
    
    T results;
    try {
      results = responseBody as T;
    } catch (_, stackTrace) {
      return throw ErrorX.createErrorByCode(
        ErrorCodesX.dataTypeMismatch,
        stackTrace: stackTrace,
        details: {
          'Expected type': T.runtimeType.toString(),
          "Current type": responseBody.runtimeType.runtimeType.toString(),
        },
      );
    }

    // Success response
    // If the status code is in the category 2xx (200-299), return the parsed results.
    // استجابة ناجحة
    // إذا كان رمز الحالة في الفئة 2xx (200-299)، يتم إرجاع النتائج المحللة.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return results;
    } else {
      // Handle errors
      // If status code is 401 and ignoreUnauthorized is true,
      // return the fallback response. Otherwise, throw an error.
      // معالجة الأخطاء
      // إذا كان رمز الحالة هو 401 وكان ignoreUnauthorized صحيحًا،
      // يتم إرجاع الاستجابة البديلة. خلاف ذلك، يتم طرح خطأ.
      if (response.statusCode == 401 && ignoreUnauthorized) {
        return fallbackResponse;
      } else {
        return throw ErrorX.createErrorByCode(
          response.statusCode,
          details: results is Map<String, dynamic> ? results : {'result': results},
        );
      }
    }
  }
}
