import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TahlilTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> tahlilGecmisi;
  final String parametre;
  final String birim;

  const TahlilTrendChart({
    Key? key,
    required this.tahlilGecmisi,
    required this.parametre,
    required this.birim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tahlilGecmisi.isEmpty) {
      return const Text('Trend verisi bulunamadı.');
    }
    final List<FlSpot> spots = [];
    final List<String> labels = [];
    for (int i = 0; i < tahlilGecmisi.length; i++) {
      final tarih = tahlilGecmisi[i]['tarih'] as String?;
      final val = tahlilGecmisi[i][parametre];
      if (val != null && tarih != null) {
        double? y;
        if (val is num) {
          y = val.toDouble();
        } else if (val is String) {
          y = double.tryParse(val.replaceAll(',', '.'));
        }
        if (y != null) {
          spots.add(FlSpot(i.toDouble(), y));
          labels.add(tarih);
        }
      }
    }
    if (spots.length < 2) {
      return const Text('Grafik için yeterli veri yok.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.cyan,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < labels.length) {
                        return Transform.rotate(
                          angle: -0.5,
                          child: Text(labels[idx], style: const TextStyle(fontSize: 11)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTrendSummary(spots, parametre, birim),
      ],
    );
  }

  Widget _buildTrendSummary(List<FlSpot> spots, String parametre, String birim) {
    if (spots.length < 2) return const SizedBox.shrink();
    final first = spots.first.y;
    final last = spots.last.y;
    final fark = (last - first).toStringAsFixed(2);
    String trend;
    if (last > first) {
      trend = 'Yükselme var (+$fark $birim)';
    } else if (last < first) {
      trend = 'Düşüş var ($fark $birim)';
    } else {
      trend = 'Değişiklik yok';
    }
    return Row(
      children: [
        const Icon(Icons.trending_up, color: Colors.cyan),
        const SizedBox(width: 7),
        Text('$parametre trendi: $trend', style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}
