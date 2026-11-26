import 'package:dio/dio.dart';
import 'package:wua_mobile/core/network/api_constants.dart';
import 'package:wua_mobile/core/network/dio_error_mapper.dart';

/// Production-grade HTTP client wrapping [Dio].
///
/// Provides typed methods for common HTTP verbs with automatic
/// error mapping via [DioErrorMapper]. Interceptors are composed
/// externally via [NetworkModule] to keep the client focused on
/// request execution.
class ApiClient {
  ApiClient({required this.dio});
  final Dio dio;

  /// Extracts a typed list of JSON objects from either a raw JSON array or a Spring Page `{content: [...]}`.
  static List<Map<String, dynamic>> extractListData(dynamic data) {
    if (data is List<dynamic>) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    if (data is Map<dynamic, dynamic> && data['content'] is List<dynamic>) {
      return (data['content'] as List<dynamic>)
          .whereType<Map<dynamic, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  /// Performs a GET request and returns the response data.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.mapDioException(e);
    }
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.mapDioException(e);
    }
  }

  /// Performs a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.mapDioException(e);
    }
  }

  /// Performs a PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.mapDioException(e);
    }
  }

  /// Performs a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.mapDioException(e);
    }
  }

  /// Uploads a file via multipart form data.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: formData,
        options: Options(contentType: ApiConstants.multipartFormData),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.mapDioException(e);
    }
  }
}
