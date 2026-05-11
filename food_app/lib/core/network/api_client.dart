import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    if (kDebugMode) {
      debugPrint('[API] Base URL: ${_dio.options.baseUrl}');
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
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

  void _logRequest(RequestOptions options) {
    if (!kDebugMode) {
      return;
    }
    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = 'Bearer ***';
    }
    debugPrint(
      '[API][REQ] ${options.method} ${options.uri}\n'
      'query=${options.queryParameters}\n'
      'headers=$headers\n'
      'body=${_safeEncode(options.data)}',
    );
  }

  void _logResponse(Response<dynamic> response) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(
      '[API][RES] ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      'status=${response.statusCode}\n'
      'data=${_safeEncode(response.data)}',
    );
  }

  void _logError(DioException error) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(
      '[API][ERR] ${error.requestOptions.method} ${error.requestOptions.uri}\n'
      'type=${error.type}\n'
      'status=${error.response?.statusCode}\n'
      'message=${error.message}\n'
      'data=${_safeEncode(error.response?.data)}',
    );
  }

  String _safeEncode(dynamic value) {
    if (value == null) {
      return 'null';
    }
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

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
