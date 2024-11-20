import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart'; // Asegúrate de importar tu servicio API
import '../widgets/brand_form_dialog.dart'; // Importa el diálogo de formulario de marcas

class BrandsPage extends StatefulWidget {
  @override
  _BrandsPageState createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  List<Map<String, dynamic>> _brands = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _limit = 10;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands({int page = 1}) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final skip = (page - 1) * _limit;
      final brands = await apiService.getVehicleBrands(skip: skip, limit: _limit);
      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching vehicle brands: $e');
    }
  }

  Future<void> _addBrand() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      try {
        await apiService.createVehicleBrand(name);
        _nameController.clear();
        await _fetchBrands(page: _currentPage); // Refrescar la lista de marcas
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marca agregada correctamente')),
        );
      } catch (e) {
        print('Error adding brand: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error agregando la marca')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre de la marca no puede estar vacío')),
      );
    }
  }

  void _updateBrand(Map<String, dynamic> brand) {
    setState(() {
      final index = _brands.indexWhere((b) => b['id'] == brand['id']);
      if (index != -1) {
        _brands[index] = brand;
      }
    });
  }

  Future<void> _deleteBrand(int id) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.deleteVehicleBrand(id);
      setState(() {
        _brands.removeWhere((b) => b['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marca eliminada correctamente')),
      );
    } catch (e) {
      print('Error deleting brand: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando la marca')),
      );
    }
  }

  Future<void> _confirmDeleteBrand(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta marca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _deleteBrand(id);
    }
  }

  Future<void> _showBrandFormDialog(Map<String, dynamic>? brand) async {
    final updatedBrand = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => BrandFormDialog(brand: brand),
    );
    if (updatedBrand != null) {
      if (brand == null) {
        _addBrand();
      } else {
        _updateBrand(updatedBrand);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marca actualizada correctamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Gestión de Marcas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Descripción
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Esta página permite gestionar las marcas de vehículos. Aquí puedes agregar, editar o eliminar marcas según sea necesario.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            // Separador
            Divider(color: Colors.grey),
            SizedBox(height: 16),
            // Tarjetas horizontales
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera tarjeta
                Expanded(
                  flex: 2,
                  child: Card(
                    color: Colors.white, // Fondo blanco para la tarjeta
                    elevation: 4,
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Listado de Marcas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _brands.length,
                                      itemBuilder: (context, index) {
                                        final brand = _brands[index];
                                        final isEven = index % 2 == 0;
                                        return Container(
                                          color: isEven ? Colors.white : Colors.grey[200],
                                          child: ListTile(
                                            title: Text(
                                              brand['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                                                  onPressed: () => _showBrandFormDialog(brand),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _confirmDeleteBrand(brand['id']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildPagination(),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Segunda tarjeta
                Expanded(
                  flex: 1,
                  child: Card(
                    color: Colors.white, // Fondo blanco para la tarjeta
                    elevation: 4,
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agregar una Marca',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addBrand,
                            child: Text('Agregar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                      _fetchBrands(page: _currentPage);
                    });
                  }
                : null,
            child: Text('Anterior'),
          ),
          SizedBox(width: 16),
          Text(
            'Página $_currentPage',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPage++;
                _fetchBrands(page: _currentPage);
              });
            },
            child: Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}