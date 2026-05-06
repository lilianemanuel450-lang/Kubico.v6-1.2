import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Logger APENAS em modo debug — nunca em produção
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          enabled: kDebugMode, // dupla garantia
        ),
      );
    }

    // Interceptor de retry em falha de rede
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Tempo de ligação esgotado. Verifica a tua internet.',
              ),
            );
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }
}
