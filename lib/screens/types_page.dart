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
  int _currentPage = 1;
  final int _limit = 10;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTypes();
  }

  Future<void> _fetchTypes({int page = 1}) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final skip = (page - 1) * _limit;
      final types = await apiService.getVehicleTypes();
      setState(() {
        _types = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching vehicle types: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los tipos de vehículos.')),
      );
    }
  }

  Future<void> _addType() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      try {
        await apiService.createVehicleType(name);
        _nameController.clear();
        await _fetchTypes(page: _currentPage); // Refrescar la lista de tipos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tipo de vehículo agregado correctamente')),
        );
      } catch (e) {
        print('Error adding type: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error agregando el tipo de vehículo')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre del tipo de vehículo no puede estar vacío')),
      );
    }
  }

  void _updateType(Map<String, dynamic> type) {
    setState(() {
      final index = _types.indexWhere((t) => t['id'] == type['id']);
      if (index != -1) {
        _types[index] = type;
      }
    });
  }

  Future<void> _deleteType(int id) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.deleteVehicleType(id);
      setState(() {
        _types.removeWhere((t) => t['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tipo de vehículo eliminado correctamente')),
      );
    } catch (e) {
      print('Error deleting type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando el tipo de vehículo')),
      );
    }
  }

  Future<void> _confirmDeleteType(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este tipo de vehículo?'),
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
      await _deleteType(id);
    }
  }

  Future<void> _showTypeFormDialog(Map<String, dynamic>? type) async {
    final updatedType = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TypeFormDialog(type: type),
    );
    if (updatedType != null) {
      if (type == null) {
        _addType();
      } else {
        _updateType(updatedType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tipo de vehículo actualizado correctamente')),
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
                'Gestión de Tipos de Vehículos',
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
                'Esta página permite gestionar los tipos de vehículos. Aquí puedes agregar, editar o eliminar tipos según sea necesario.',
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
                            'Listado de Tipos de Vehículos',
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
                                      itemCount: _types.length,
                                      itemBuilder: (context, index) {
                                        final type = _types[index];
                                        final isEven = index % 2 == 0;
                                        return Container(
                                          color: isEven ? Colors.white : Colors.grey[200],
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
                                                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                                                  onPressed: () => _showTypeFormDialog(type),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _confirmDeleteType(type['id']),
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
                            'Agregar un Tipo de Vehículo',
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
                            onPressed: _addType,
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
                      _fetchTypes(page: _currentPage);
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
                _fetchTypes(page: _currentPage);
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

class TypeFormDialog extends StatefulWidget {
  final Map<String, dynamic>? type;

  TypeFormDialog({this.type});

  @override
  _TypeFormDialogState createState() => _TypeFormDialogState();
}

class _TypeFormDialogState extends State<TypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.type?['type_name'] ?? '';
  }

  Future<void> _saveType() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        final type = {
          'id': widget.type?['id'] ?? 0,
          'type_name': _nameController.text.trim(),
        };
        if (widget.type == null) {
          await apiService.createVehicleType(_nameController.text.trim());
        } else {
          await apiService.updateVehicleType(type['id'], _nameController.text.trim());
        }
        Navigator.pop(context, type);
      } catch (e) {
        print('Error saving type: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving type')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.type == null ? 'Agregar Tipo de Vehículo' : 'Editar Tipo de Vehículo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveType,
          child: _isSaving ? CircularProgressIndicator() : Text('Guardar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}