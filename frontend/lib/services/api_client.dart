import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ApiClient {
  late Dio dio;
  final String baseUrl = "http://127.0.0.1:8000/api/";
  static const String _tokenKey = 'auth_token';
  final Box _settingsBox;
  VoidCallback? onUnauthorized;

  ApiClient(this._settingsBox) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));

    print("ApiClient initialized. Base URL: $baseUrl");
    final token = _settingsBox.get(_tokenKey);
    if (token != null && token.toString().isNotEmpty) {
      print("ApiClient: Token found in storage, setting Authorization header.");
      dio.options.headers["Authorization"] = "Bearer $token";
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("DIO Request: ${options.method} ${options.uri}");
        // Check if token exists in storage but not in headers (stale client)
        if (!options.headers.containsKey("Authorization")) {
          final savedToken = _settingsBox.get(_tokenKey);
          if (savedToken != null) {
            options.headers["Authorization"] = "Bearer $savedToken";
          }
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print("DIO Error: [${e.response?.statusCode}] ${e.requestOptions.path}");
        if (e.response != null && e.response?.data is Map) {
          final data = e.response!.data as Map;
          print("DIO Error Detail: ${data['detail'] ?? data['error'] ?? data['traceback'] ?? 'No detail'}");
        }

        if (e.response?.statusCode == 401) {
          print("ApiClient: 401 Detected, triggering logout callback.");
          clearToken();
          onUnauthorized?.call();
        }

        return handler.next(e);
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  void setToken(String token) {
    print("ApiClient: Setting token");
    _settingsBox.put(_tokenKey, token);
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  void clearToken() {
    _settingsBox.delete(_tokenKey);
    dio.options.headers.remove("Authorization");
  }

  bool get hasToken => _settingsBox.containsKey(_tokenKey);
}
