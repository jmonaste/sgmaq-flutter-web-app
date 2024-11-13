// FILE: vehicle_registrations_chart.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class VehicleRegistrationsChart extends StatefulWidget {
  @override
  _VehicleRegistrationsChartState createState() => _VehicleRegistrationsChartState();
}

class _VehicleRegistrationsChartState extends State<VehicleRegistrationsChart> {
  bool _isLoading = true;
  List<VehicleRegistration> _registrations = [];

  @override
  void initState() {
    super.initState();
    _fetchRegistrations();
  }

  Future<void> _fetchRegistrations() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final registrations = await apiService.getVehicleRegistrationsByDate();
      setState(() {
        _registrations = registrations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching vehicle registrations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_registrations.isEmpty) {
      return Center(child: Text('No hay registros de vehículos disponibles.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: _registrations.length.toDouble() - 1,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: _buildBottomTitle,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _createSpots(),
              isCurved: true,
              barWidth: 2,
              color: Colors.blueAccent,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createSpots() {
    return List.generate(_registrations.length, (index) {
      final reg = _registrations[index];
      final x = index.toDouble();
      final y = reg.count.toDouble();
      return FlSpot(x, y);
    });
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index < 0 || index >= _registrations.length) return Container();
    final date = _registrations[index].date;
    final formatter = DateFormat('MM-dd');
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(formatter.format(date), style: TextStyle(fontSize: 10)),
    );
  }
}
