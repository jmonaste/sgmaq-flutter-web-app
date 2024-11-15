// FILE: home_page.dart
import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Importa el nuevo archivo
import 'types_page.dart'; // Importa el nuevo archivo types_page.dart
import '../brands_page.dart'; // Importa el nuevo archivo brands_page.dart
import 'models_page.dart'; // Importa el nuevo archivo models_page.dart

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Índice para el elemento seleccionado en la barra lateral

  // Lista de páginas para navegar (puedes agregar tus propias páginas aquí)
  final List<Widget> _pages = [
    DashboardPage(), // Usa el nuevo widget
    TypesPage(), // Usa el nuevo widget TypesPage
    BrandsPage(), // Usa el nuevo widget BrandsPage
    ModelsPage(), // Usa el nuevo widget ModelsPage
    Center(child: Text('Vehículos')),
    Center(child: Text('Configuración')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definir la paleta de colores
    final Color primaryColor = Colors.grey[800]!;
    final Color accentColor = Colors.blueAccent;
    final Color backgroundColor = Colors.white;
    final Color selectedColor = Colors.blueGrey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // Barra lateral
          Container(
            width: 250,
            color: primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Logo de ejemplo
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Image.asset(
                    'assets/sgmaq-logo-webapp.png',
                    width: 200,
                    height: 100,
                  ),
                ),
                // Opciones de navegación
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuItem(Icons.dashboard, 'Dashboard', 0),
                      _buildMenuItem(Icons.category, 'Tipos', 1),
                      _buildMenuItem(Icons.branding_watermark, 'Marcas', 2),
                      _buildMenuItem(Icons.drive_eta, 'Modelos', 3),
                      _buildMenuItem(Icons.directions_car, 'Vehículos', 4),
                      _buildMenuItem(Icons.settings, 'Configuración', 5),
                    ],
                  ),
                ),
                // Logout al final
                Divider(color: Colors.grey),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Acción de logout
                  },
                ),
              ],
            ),
          ),
          // Contenido de la página seleccionada
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue[700],
      onTap: () => _onItemTapped(index),
    );
  }
}