// FILE: types_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart'; // Asegúrate de importar tu servicio API

class TypesPage extends StatefulWidget {
  @override
  _TypesPageState createState() => _TypesPageState();
}

class _TypesPageState extends State<TypesPage> {
  List<Map<String, dynamic>> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final types = await apiService.getVehicleTypes();
      setState(() {
        _types = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar el error apropiadamente
      print('Error fetching vehicle types: $e');
    }
  }

  void _addType(Map<String, dynamic> type) {
    setState(() {
      _types.add(type);
    });
  }

  void _updateType(Map<String, dynamic> type) {
    setState(() {
      final index = _types.indexWhere((t) => t['id'] == type['id']);
      if (index != -1) {
        _types[index] = type;
      }
    });
  }

  void _deleteType(int id) {
    setState(() {
      _types.removeWhere((t) => t['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tipos de Vehículos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Eliminamos la sombra para un diseño más plano
        iconTheme: IconThemeData(color: Colors.black), // Iconos en negro
      ),
      backgroundColor: Colors.grey[100], // Fondo gris claro
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _types.isEmpty
                      ? Center(
                          child: Text(
                            'No hay tipos de vehículos disponibles.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _types.length,
                          itemBuilder: (context, index) {
                            final type = _types[index];
                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                title: Text(
                                  type['type_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        final updatedType = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TypeFormPage(type: type),
                                          ),
                                        );
                                        if (updatedType != null) {
                                          _updateType(updatedType);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await apiService
                                            .deleteVehicleType(type['id']);
                                        _deleteType(type['id']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Botón para agregar un nuevo tipo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final newType = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TypeFormPage()),
                        );
                        if (newType != null) {
                          _addType(newType);
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text('Agregar Tipo de Vehículo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class TypeFormPage extends StatefulWidget {
  final Map<String, dynamic>? type;

  TypeFormPage({this.type});

  @override
  _TypeFormPageState createState() => _TypeFormPageState();
}

class _TypeFormPageState extends State<TypeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  bool _isSaving = false; // Para mostrar un indicador de carga al guardar

  @override
  void initState() {
    super.initState();
    _name = widget.type?['type_name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == null ? 'Agregar Tipo' : 'Editar Tipo',
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
                  widget.type == null
                      ? 'Nuevo Tipo de Vehículo'
                      : 'Editar Tipo de Vehículo',
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
                                final type = {
                                  'id': widget.type?['id'] ?? 0,
                                  'type_name': _name
                                };
                                if (widget.type == null) {
                                  await apiService.createVehicleType(_name);
                                } else {
                                  await apiService.updateVehicleType(
                                      type['id'], _name);
                                }
                                setState(() {
                                  _isSaving = false;
                                });
                                Navigator.pop(context, type);
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
                              widget.type == null ? 'Agregar' : 'Actualizar',
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
