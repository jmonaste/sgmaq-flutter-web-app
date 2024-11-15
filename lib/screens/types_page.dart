// FILE: types_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart'; // Asegúrate de importar tu servicio API

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
      _showErrorSnackbar('Error al obtener los tipos de vehículos.');
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showTypeForm({Map<String, dynamic>? type}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TypeFormDialog(type: type),
    );

    if (result != null) {
      if (type == null) {
        _addType(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tipo agregado exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _updateType(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tipo actualizado exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tipos de Vehículos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal, // Color más suave y profesional
        elevation: 4, // Añade una sombra sutil para profundidad
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchTypes();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50], // Fondo más claro y limpio
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTypeForm();
        },
        backgroundColor: Colors.teal, // Consistente con el AppBar
        tooltip: 'Agregar Tipo de Vehículo',
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800), // Limita el ancho máximo
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                )
              : _types.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey, size: 80),
                          SizedBox(height: 16),
                          Text(
                            'No hay tipos de vehículos disponibles.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.separated(
                        itemCount: _types.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final type = _types[index];
                          return Card(
                            color: Colors.teal[50], // Color de fondo suave
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              title: Text(
                                type['type_name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal[800],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.orangeAccent),
                                    onPressed: () {
                                      _showTypeForm(type: type);
                                    },
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Confirmar Eliminación'),
                                          content: Text(
                                              '¿Estás seguro de que deseas eliminar este tipo?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(false),
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(true),
                                              child: Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != null && confirm) {
                                        try {
                                          await apiService.deleteVehicleType(type['id']);
                                          _deleteType(type['id']);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Tipo eliminado exitosamente.'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          _showErrorSnackbar(
                                              'Error al eliminar el tipo.');
                                        }
                                      }
                                    },
                                    tooltip: 'Eliminar',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

class TypeFormDialog extends StatefulWidget {
  final Map<String, dynamic>? type;

  TypeFormDialog({this.type});

  @override
  _TypeFormDialogState createState() => _TypeFormDialogState();
}

class _TypeFormDialogState extends State<TypeFormDialog> {
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
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0), // Espaciado interno
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.type == null ? 'Agregar Tipo' : 'Editar Tipo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Colors.teal[600]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.redAccent),
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
              ),
              SizedBox(height: 24),
              SizedBox(
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
                            try {
                              if (widget.type == null) {
                                final newType =
                                    await apiService.createVehicleType(_name);
                                //type['id'] = newType['id']; // Actualiza el ID
                              } else {
                                await apiService.updateVehicleType(
                                    type['id'], _name);
                              }
                              setState(() {
                                _isSaving = false;
                              });
                              Navigator.of(context).pop(type);
                            } catch (e) {
                              setState(() {
                                _isSaving = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al guardar el tipo.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Consistente con el AppBar
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
