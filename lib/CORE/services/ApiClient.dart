import 'dart:convert';

import 'package:application_front/CORE/repositories/User.dart';
import '../repositories/LoginRequest.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final String url;
  late final Dio _dio;

  ApiClient({required this.url}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        contentType: Headers.formUrlEncodedContentType, // Важное изменение!
      ),
    );
    _dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  }

  Map<String, dynamic> _GetHeaders(String? authToken, [bool assJson = false]) {
    final headers = <String, dynamic>{};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    if(assJson)
    {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<Response> Get(String path, UserInfo user, {Map<String, dynamic>? queryParameters}) async {
    try {
      late Response response;
      await user.UseToken((token) async
      {
        response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: Options(headers: _GetHeaders(token)),
        );
      });
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> PostAuth(LoginRequest data) async {
    try {
      String path = '/auth';
      
      final response = await _dio.post(
        path,
        options: Options(headers: _GetHeaders(null, true)),
        data: data.toJson()
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Exception('Превышено время ожидания соединения');
        case DioExceptionType.receiveTimeout:
          return Exception('Превышено время ожидания ответа');
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return Exception('401');
          }
          return Exception('Ошибка сервера: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return Exception('Запрос был отменен');
        case DioExceptionType.badCertificate:
          return Exception('Ошибка сертификата');
        default:
          return Exception('Произошла ошибка при запросе: ${error.message}');
      }
    }
    return Exception('Неизвестная ошибка');
  }
}