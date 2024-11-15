// lib/auth_service.dart
import '../utils/constants.dart'; // Importa baseUrl
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para almacenar el token de forma segura
import 'dart:convert'; // Para jsonEncode y jsonDecode
import 'package:flutter/material.dart'; // Para acceder a NavigatorState
import '../screens/login_screen.dart'; // Para redirigir al login

class AuthService {
  late final Dio dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final GlobalKey<NavigatorState> navigatorKey;

  AuthService(this.navigatorKey) {
      dio = Dio(
        BaseOptions(
          baseUrl: baseUrl, // Usa baseUrl de constants.dart
          connectTimeout: Duration(milliseconds: 5000), // Tiempo de espera de conexión en ms
          receiveTimeout: Duration(milliseconds: 3000), // Tiempo de espera de recepción en ms
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            // Permitir que el interceptor maneje el error 401 sin lanzar una excepción
            return status != null && status < 500;
          },
        ),
      );

      // Añadir Logging Interceptor (opcional)
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => print(obj),
      ));

      // Añadir otros interceptores
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            RequestOptions options = error.requestOptions;

            bool tokenRefreshed = await refreshAccessToken();
            if (tokenRefreshed) {
              String? newAccessToken = await getAccessToken();
              if (newAccessToken != null) {
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final cloneReq = await dio.request(
                  options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters,
                );
                return handler.resolve(cloneReq);
              }
            }

            // Si la renovación falla, redirigir al usuario al login
            await clearTokens();
            _navigateToLogin();
            
          } else if (error.response?.statusCode == 401) {
            // Manejar el error 401 Unauthorized
            final responseData = error.response?.data;
            if (responseData != null && responseData['detail'] == 'Incorrect username or password') {
              _showErrorMessage('Nombre de usuario o contraseña incorrectos');
            }
          }
          return handler.next(error);
        },
      ));
    }

  void _navigateToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> clearTokens() async {
    // Implementa la lógica para limpiar los tokens
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      throw Exception('No se encontró el token de refresco');
    }
    try {
      final response = await dio.post(
        '/api/refresh',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'accessToken', value: data['access_token']);
        await _storage.write(key: 'refreshToken', value: data['refresh_token']);
        return true;
      } else {
        throw Exception('Error al refrescar el token');
      }
    } catch (e) {
      throw Exception('Error al refrescar el token: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
          'scope': '',
          'client_id': 'string',
          'client_secret': 'string',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'accessToken', value: data['access_token']);
        await _storage.write(key: 'refreshToken', value: data['refresh_token']);
      } else {
        throw Exception('Error al iniciar sesión');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }
}
