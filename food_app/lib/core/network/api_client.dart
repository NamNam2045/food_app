import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
    : _tokenStorage = tokenStorage,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              headers: const {'Content-Type': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.error is ApiException) {
            handler.next(error);
            return;
          }
          final response = error.response;
          if (response?.data is Map<String, dynamic>) {
            final json = response!.data as Map<String, dynamic>;
            handler.next(
              DioException(
                requestOptions: error.requestOptions,
                response: response,
                error: ApiException(
                  message: (json['message'] ?? 'Đã xảy ra lỗi').toString(),
                  errorCode: json['errorCode']?.toString(),
                  statusCode: response.statusCode,
                  details: (json['details'] as List?)
                      ?.map((e) => e.toString())
                      .toList(growable: false),
                ),
                type: error.type,
                stackTrace: error.stackTrace,
              ),
            );
            return;
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: query,
      options: options,
    );
    return _unwrap(response);
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: body,
      queryParameters: query,
      options: options,
    );
    return _unwrap(response);
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final response = await _dio.put<dynamic>(
      path,
      data: body,
      queryParameters: query,
      options: options,
    );
    return _unwrap(response);
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final response = await _dio.patch<dynamic>(
      path,
      data: body,
      queryParameters: query,
      options: options,
    );
    return _unwrap(response);
  }

  Future<dynamic> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final response = await _dio.delete<dynamic>(
      path,
      data: body,
      queryParameters: query,
      options: options,
    );
    return _unwrap(response);
  }

  dynamic _unwrap(Response<dynamic> response) {
    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      final bool success = payload['success'] == true;
      if (!success) {
        throw ApiException(
          message: (payload['message'] ?? 'Đã xảy ra lỗi').toString(),
          errorCode: payload['errorCode']?.toString(),
          statusCode: response.statusCode,
          details: (payload['details'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false),
        );
      }
      return payload['data'];
    }
    return payload;
  }
}
