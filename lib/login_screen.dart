import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Por favor, introduzca tanto el nombre de usuario como la contraseña.');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.login(username, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      _showErrorDialog('Error al iniciar sesión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
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
