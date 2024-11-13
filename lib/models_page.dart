// FILE: models_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ModelsPage extends StatelessWidget {
  // Datos de ejemplo que incluyen años 2023 y 2024, meses y cantidades
  final List<Map<String, dynamic>> data = [
    {'year': 2023, 'month': 1, 'value': 5},
    {'year': 2023, 'month': 3, 'value': 6},
    {'year': 2023, 'month': 5, 'value': 10},
    {'year': 2023, 'month': 7, 'value': 7},
    {'year': 2023, 'month': 9, 'value': 12},
    {'year': 2023, 'month': 11, 'value': 9},
    {'year': 2024, 'month': 1, 'value': 15},
    {'year': 2024, 'month': 3, 'value': 10},
    {'year': 2024, 'month': 5, 'value': 20},
    {'year': 2024, 'month': 7, 'value': 18},
    {'year': 2024, 'month': 9, 'value': 25},
    {'year': 2024, 'month': 11, 'value': 30},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modelos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.5, // Más ancho que alto
          children: List.generate(4, (index) {
            return _buildLineChart();
          }),
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

  // Función auxiliar para convertir el número del mes en el nombre correspondiente
  String _getMonthName(int month) {
    const monthNames = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return month >= 1 && month <= 12 ? monthNames[month - 1] : '';
  }




}
