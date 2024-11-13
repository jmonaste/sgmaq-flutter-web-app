// FILE: brands_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart'; // Asegúrate de importar tu servicio API

class BrandsPage extends StatefulWidget {
  @override
  _BrandsPageState createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  List<Map<String, dynamic>> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final brands = await apiService.getVehicleBrands();
      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar el error apropiadamente
      print('Error fetching vehicle brands: $e');
    }
  }

  void _addBrand(Map<String, dynamic> brand) {
    setState(() {
      _brands.add(brand);
    });
  }

  void _updateBrand(Map<String, dynamic> brand) {
    setState(() {
      final index = _brands.indexWhere((b) => b['id'] == brand['id']);
      if (index != -1) {
        _brands[index] = brand;
      }
    });
  }

  void _deleteBrand(int id) {
    setState(() {
      _brands.removeWhere((b) => b['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Marcas de Vehículos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Eliminamos la sombra para un diseño más plano
        iconTheme: IconThemeData(color: Colors.black), // Iconos en negro
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newBrand = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrandFormPage()),
              );
              if (newBrand != null) {
                _addBrand(newBrand);
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100], // Fondo gris claro
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _brands.isEmpty
                  ? Center(
                      child: Text(
                        'No hay marcas de vehículos disponibles.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _brands.length,
                      itemBuilder: (context, index) {
                        final brand = _brands[index];
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                  icon:
                                      Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () async {
                                    final updatedBrand = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BrandFormPage(brand: brand),
                                      ),
                                    );
                                    if (updatedBrand != null) {
                                      _updateBrand(updatedBrand);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await apiService
                                        .deleteVehicleBrand(brand['id']);
                                    _deleteBrand(brand['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class BrandFormPage extends StatefulWidget {
  final Map<String, dynamic>? brand;

  BrandFormPage({this.brand});

  @override
  _BrandFormPageState createState() => _BrandFormPageState();
}

class _BrandFormPageState extends State<BrandFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.brand?['name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.brand == null ? 'Agregar Marca' : 'Editar Marca',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Eliminamos la sombra
        iconTheme: IconThemeData(color: Colors.black), // Iconos en negro
      ),
      backgroundColor: Colors.grey[100], // Fondo gris claro
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0), // Más espacio alrededor del formulario
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.brand == null
                      ? 'Nueva Marca de Vehículo'
                      : 'Editar Marca de Vehículo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  _isSaving = true;
                                });
                                final brand = {
                                  'id': widget.brand?['id'] ?? 0,
                                  'name': _name
                                };
                                if (widget.brand == null) {
                                  await apiService.createVehicleBrand(_name);
                                } else {
                                  await apiService.updateVehicleBrand(
                                      brand['id'], _name);
                                }
                                setState(() {
                                  _isSaving = false;
                                });
                                Navigator.pop(context, brand);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),                            
                      child: _isSaving
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.brand == null ? 'Agregar' : 'Actualizar',
                              style: TextStyle(fontSize: 16),
                            ),
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
