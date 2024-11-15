// lib/auth_service.dart
import 'dart:async';
import 'package:flutter/material.dart'; // Para acceder a NavigatorState
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para almacenar el token de forma segura
import '../utils/constants.dart'; // Importa baseUrl
import '../screens/login_screen.dart'; // Para redirigir al login

class AuthService {
  late final Dio dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final GlobalKey<NavigatorState> navigatorKey;

  AuthService(this.navigatorKey) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: 5000),
        receiveTimeout: Duration(milliseconds: 3000),
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
          // Diferenciar entre solicitudes de inicio de sesión y otras solicitudes
          if (error.requestOptions.path == '/login') {
            // Manejar credenciales incorrectas
            final responseData = error.response?.data;
            String errorMessage = 'Nombre de usuario o contraseña incorrectos.';
            if (responseData != null && responseData['detail'] != null) {
              errorMessage = responseData['detail'];
            }
            // Mostrar mensaje de error en la UI
            _showErrorMessage(errorMessage);
            return handler.next(error); // Permitir que la UI maneje el error
          } else {
            // Manejar la renovación del token para otras solicitudes
            RequestOptions options = error.requestOptions;
            bool tokenRefreshed = await refreshAccessToken();
            if (tokenRefreshed) {
              String? newAccessToken = await getAccessToken();
              if (newAccessToken != null) {
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                try {
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
                } catch (e) {
                  // Si la solicitud clonada falla, manejar el error
                  return handler.next(e as DioException);
                }
              }
            }

            // Si la renovación falla, redirigir al usuario al login
            await clearTokens();
            _navigateToLogin();
          }
        }
        return handler.next(error);
      },
    ));
  }

  // Navegar a la pantalla de login
  void _navigateToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  // Limpiar tokens almacenados
  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  // Mostrar mensaje de error usando SnackBar
  void _showErrorMessage(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Obtener el token de acceso almacenado
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // Obtener el token de renovación almacenado
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  // Renovar el token de acceso usando el token de renovación
  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    try {
      final response = await dio.post(
        '/api/refresh', // Asegúrate de que esta sea la ruta correcta para renovar el token
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'accessToken', value: data['access_token']);
        await _storage.write(key: 'refreshToken', value: data['refresh_token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error al renovar el token: $e');
      return false;
    }
  }

  // Método de inicio de sesión
  Future<void> login(String username, String password) async {
    try {
      final response = await dio.post('/login',
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
        // Lanzar una excepción específica para manejar el error en la UI
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse, // Actualizado a badResponse
          error: 'Incorrect username or password: ${response.statusCode}',
        );
      }
    } on DioException {
      // Re-throw la excepción para que el interceptor la maneje
      rethrow;
    } catch (e) {
      throw DioException(requestOptions: RequestOptions(path: '/login'),
        error: 'Error al iniciar sesión: $e',
        type: DioExceptionType.unknown,
      );
    }
  }

  // Método de cierre de sesión
  Future<void> logout() async {
    await clearTokens();
    _navigateToLogin();
  }
}
