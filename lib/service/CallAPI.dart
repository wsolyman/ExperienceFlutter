import 'package:dio/dio.dart';

import 'package:dio/dio.dart';

class CallAPI {
  final Dio _dio = Dio();

  CallAPI({BaseOptions? options}) {
    if (options != null) _dio.options = options;
  }

  /// GET a list (e.g. /cities) -> returns ApiResponse<List<T>>
  Future<ApiResponse<List<T>>> getList<T>({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        if (data is List) {
          final List<T> list = data.map<T>((e) => fromJson(e)).toList();
          return ApiResponse.success(list);
        } else {
          // response is not a list
          return ApiResponse.error('Expected a list but got: ${data.runtimeType}');
        }
      } else {
        return ApiResponse.error(
          'HTTP Error: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioError catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// GET a single item (e.g. /users/1) -> returns ApiResponse<T>
  Future<ApiResponse<T>> getItem<T>({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        if (data is Map<String, dynamic> || data is Map) {
          return ApiResponse.success(fromJson(data));
        } else {
          return ApiResponse.error('Expected an object but got: ${data.runtimeType}');
        }
      } else {
        return ApiResponse.error(
          'HTTP Error: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioError catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  String _handleDioError(DioError e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioErrorType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Received invalid status code: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return e.message!;
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse._({required this.success, this.data, this.error});

  factory ApiResponse.success(T data) => ApiResponse._(success: true, data: data);

  factory ApiResponse.error(String error) => ApiResponse._(success: false, error: error);
}

