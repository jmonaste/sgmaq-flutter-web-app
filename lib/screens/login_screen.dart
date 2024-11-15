// lib/login_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/dialogs.dart';
import '../utils/strings.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      DialogHelper.showErrorDialog(context, LoginStrings.usernameOrPasswordEmpty);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authService.login(username, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() {
        print(e);
        _errorMessage = e.toString().contains('Incorrect username or password')
            ? LoginStrings.incorrectUsernameOrPassword
            : '${LoginStrings.loginError} $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // Definir una paleta de colores más sobria
    final Color primaryColor = Colors.grey[800]!;
    final Color accentColor = Colors.blueAccent;
    final Color backgroundColor = Colors.white;
    final Color textFieldBackground = Colors.grey[200]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400), // Limitar el ancho máximo
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24), // Aumentar el padding horizontal
            child: ListView(
              shrinkWrap: true, // Ajustar la altura del ListView al contenido
              children: [
                SizedBox(height: screenHeight * .12),
                Text(
                  'Bienvenido,',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center, // Centrar el texto
                ),
                SizedBox(height: screenHeight * .01),
                Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 18,
                    color: primaryColor.withOpacity(.6),
                  ),
                  textAlign: TextAlign.center, // Centrar el texto
                ),
                SizedBox(height: screenHeight * .08),
                // Mostrar el mensaje de error si existe
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    labelStyle: TextStyle(color: Colors.blueAccent), // Color del texto del label
                    filled: true,
                    fillColor: textFieldBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Color del borde
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: Colors.blueAccent), // Color del texto que introduce el usuario
                ),
                SizedBox(height: screenHeight * .02),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.blueAccent), // Color del texto del label
                    filled: true,
                    fillColor: textFieldBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Color del borde
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: Colors.blueAccent), // Color del texto que introduce el usuario
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * .05,
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
                SizedBox(
                  height: screenHeight * .1,
                ),
                TextButton(
                  onPressed: () {},
                  child: RichText(
                    textAlign: TextAlign.center, // Centrar el texto
                    text: TextSpan(
                      text: 'Soy un nuevo usuario, ',
                      style: TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
