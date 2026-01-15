import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  String _selectedPeriod = '7';
  Map<String, dynamic>? _statsData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _error = 'Oturum bulunamadı';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/statistics/overview?days=$_selectedPeriod'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _statsData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'İstatistikler yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bağlantı hatası';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadStatistics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7', child: Text('Son 7 Gün')),
              const PopupMenuItem(value: '14', child: Text('Son 14 Gün')),
              const PopupMenuItem(value: '30', child: Text('Son 30 Gün')),
              const PopupMenuItem(value: '90', child: Text('Son 90 Gün')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStatistics,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildWeightChart(),
                        const SizedBox(height: 24),
                        _buildWorkoutChart(),
                        const SizedBox(height: 24),
                        _buildWaterChart(),
                        const SizedBox(height: 24),
                        _buildCaloriesChart(),
                        const SizedBox(height: 24),
                        _buildStepsChart(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _statsData?['summary'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Antrenman',
                '${summary['totalWorkouts'] ?? 0}',
                Icons.fitness_center,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Ort. Su',
                '${summary['avgWater'] ?? 0} ml',
                Icons.water_drop,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Ort. Kalori',
                '${summary['avgCalories'] ?? 0}',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Ort. Adım',
                '${summary['avgSteps'] ?? 0}',
                Icons.directions_walk,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    final dailyStats = (_statsData?['dailyStats'] as List?) ?? [];
    final weightData = dailyStats
        .where((stat) => stat['weight'] != null)
        .map((stat) => FlSpot(
              dailyStats.indexOf(stat).toDouble(),
              (stat['weight'] as num).toDouble(),
            ))
        .toList();

    if (weightData.isEmpty) {
      return _buildEmptyChart('Kilo Trendi', 'Kilo verisi yok');
    }

    return _buildChart(
      title: 'Kilo Trendi',
      spots: weightData,
      color: Colors.blue,
      unit: 'kg',
      dailyStats: dailyStats,
    );
  }

  Widget _buildWorkoutChart() {
    final dailyStats = (_statsData?['dailyStats'] as List?) ?? [];
    final workoutData = dailyStats
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['workoutDuration'] as num).toDouble(),
            ))
        .toList();

    return _buildChart(
      title: 'Antrenman Süresi',
      spots: workoutData,
      color: Colors.green,
      unit: 'dk',
      dailyStats: dailyStats,
    );
  }

  Widget _buildWaterChart() {
    final dailyStats = (_statsData?['dailyStats'] as List?) ?? [];
    final waterData = dailyStats
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['water'] as num).toDouble(),
            ))
        .toList();

    return _buildChart(
      title: 'Su Tüketimi',
      spots: waterData,
      color: Colors.blue,
      unit: 'ml',
      dailyStats: dailyStats,
    );
  }

  Widget _buildCaloriesChart() {
    final dailyStats = (_statsData?['dailyStats'] as List?) ?? [];
    final caloriesData = dailyStats
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['calories'] as num).toDouble(),
            ))
        .toList();

    return _buildChart(
      title: 'Kalori Alımı',
      spots: caloriesData,
      color: Colors.orange,
      unit: 'kcal',
      dailyStats: dailyStats,
    );
  }

  Widget _buildStepsChart() {
    final dailyStats = (_statsData?['dailyStats'] as List?) ?? [];
    final stepsData = dailyStats
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['steps'] as num).toDouble(),
            ))
        .toList();

    return _buildChart(
      title: 'Adım Sayısı',
      spots: stepsData,
      color: Colors.purple,
      unit: 'adım',
      dailyStats: dailyStats,
    );
  }

  Widget _buildEmptyChart(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                message,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required List<FlSpot> spots,
    required Color color,
    required String unit,
    required List dailyStats,
  }) {
    if (spots.isEmpty || spots.every((spot) => spot.y == 0)) {
      return _buildEmptyChart(title, 'Veri yok');
    }

    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dailyStats.length) return const Text('');

                        final date = DateTime.parse(dailyStats[index]['date']);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: minY > 0 ? minY * 0.9 : 0,
                maxY: maxY * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
