import 'package:dio/dio.dart';

class ApiClient {
  static Dio createDio({String baseUrl = 'http://localhost:5000'}) {
    // 10.0.2.2 points to host localhost from an Android Emulator
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
}