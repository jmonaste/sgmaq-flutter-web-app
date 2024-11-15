// FILE: dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart'; // Asegúrate de importar tu servicio API
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _vehicleCount = 0;
  int _vehiclesInProcessCount = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> data = [];


  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      // Obtener el total de vehículos
      final count = await apiService.getVehicleCount();
      // Obtener el conteo de vehículos en curso
      final inProcessCount = await apiService.getVehiclesInProcessCount();
      // Obtener los datos de registros de vehículos por fecha
      final registrationsByDate = await apiService.getVehicleRegistrationsByDate();
      
      setState(() {
        _vehicleCount = count;
        _vehiclesInProcessCount = inProcessCount;
        data = registrationsByDate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar el error apropiadamente
      print('Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo gris claro
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Total de Vehículos',
                            value: _vehicleCount.toString(),
                            icon: Icons.directions_car,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(width: 16), // Espacio entre las tarjetas
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Vehículos en Curso',
                            value: _vehiclesInProcessCount.toString(),
                            icon: Icons.build_circle,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(width: 16), // Espacio entre las tarjetas
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Vehículos en Urgencia',
                            value: _vehiclesInProcessCount.toString(),
                            icon: Icons.warning,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Vehículos lavados por mes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      height: 400, // Define una altura específica para el GridView
                      child: _buildBarChart()
                    ),
                  ],
                ),
              ),
            ),
    );
  }





  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // Genera etiquetas combinando año y mes
    final List<String> dateLabels = data.map((entry) {
      final year = entry['year'];
      final month = entry['month'];
      return '${_getMonthName(month)} $year';
    }).toList();

    // Genera puntos de datos dinámicamente
    final List<FlSpot> spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble(); // El índice será la posición en el eje X
      final value = entry.value['value'] as double; // El valor será la cantidad en el eje Y
      return FlSpot(index, value);
    }).toList();

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots, // Usa los puntos generados dinámicamente
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Muestra cada etiqueta en el eje X
                getTitlesWidget: (value, meta) {
                  // Obtén la etiqueta de fecha correspondiente al índice
                  if (value.toInt() < dateLabels.length) {
                    return Text(dateLabels[value.toInt()]);
                  } else {
                    return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5, // Intervalo entre cantidades en el eje Y
                getTitlesWidget: (value, meta) {
                  // Etiquetas de cantidades en el eje Y
                  return Text('${value.toInt()}');
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true), // Líneas de la cuadrícula
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Genera etiquetas combinando año y mes
    final List<String> dateLabels = data.map((entry) {
      final year = entry['year'];
      final month = entry['month'];
      return '${_getMonthName(month)} $year';
    }).toList();

    // Genera puntos de datos dinámicamente para las barras
    final List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
      final index = entry.key; // El índice será la posición en el eje X
      final value = entry.value['value'] as double; // El valor será la cantidad en el eje Y
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.blue,
            width: 25,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Muestra cada etiqueta en el eje X
                getTitlesWidget: (value, meta) {
                  // Obtén la etiqueta de fecha correspondiente al índice
                  if (value.toInt() < dateLabels.length) {
                    return Text(dateLabels[value.toInt()]);
                  } else {
                    return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5, // Intervalo entre cantidades en el eje Y
                getTitlesWidget: (value, meta) {
                  // Etiquetas de cantidades en el eje Y
                  return Text('${value.toInt()}');
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true), // Líneas de la cuadrícula
          borderData: FlBorderData(show: true),
          alignment: BarChartAlignment.spaceBetween,
          maxY: data.map((entry) => entry['value'] as double).reduce((a, b) => a > b ? a : b) + 5,
        ),
      ),
    );
  }




  // Función auxiliar para convertir el número del mes en el nombre correspondiente
  String _getMonthName(int month) {
    const monthNames = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return month >= 1 && month <= 12 ? monthNames[month - 1] : '';
  }



}
