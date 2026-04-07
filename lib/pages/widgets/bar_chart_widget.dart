import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vita_log/app_style.dart';
import 'package:vita_log/controller/hive_registro_controller.dart';
import 'package:vita_log/models/registro.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({super.key});

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  final Duration duration = Duration(milliseconds: 200);
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    HiveRegistroController hiveRegistroController = HiveRegistroController(
      context: context,
    );

    final List<Registro> registros = hiveRegistroController.fetch();

    final Map<int, int> countByHumor = {};

    for (var e in registros) {
      final humor = e.humorLevel.toInt();
      countByHumor[humor] = (countByHumor[humor] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Humor - BarChart', style: AppStyle.title.copyWith(color: AppStyle.primary)),
        Expanded(
          child: BarChart(
            mainBarData(countByHumor),
            duration: duration,
          ),
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(
    Map<int, int> countByHumor,
    int x, {
    bool isTouched = false,
  }) {
    final count = getCount(countByHumor, x);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          width: 22,
          borderSide: isTouched
              ? BorderSide(color: AppStyle.primary)
              : BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 5,
            color: Colors.blueGrey,
          ),
        ),
      ],
      showingTooltipIndicators: isTouched ? [0] : [],
    );
  }

  int getCount(Map<int, int> countByHumor, int level) =>
      countByHumor[level] ?? 0;

  BarChartData mainBarData(Map<int, int> countByHumor) {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${getCount(countByHumor, group.x.toInt())}',
              AppStyle.title.copyWith(color: Colors.white),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(
        6,
        (i) => makeGroupData(countByHumor, i, isTouched: i == touchedIndex),
      ),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = switch (value.toInt()) {
      0 => '😭',
      1 => '😞',
      2 => '😥',
      3 => '😐',
      4 => '😊',
      5 => '😄',
      _ => '',
    };
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: Text(text, style: style),
    );
  }
}
