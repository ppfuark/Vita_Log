import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vita_log/app_style.dart';
import 'package:vita_log/controller/hive_registro_controller.dart';
import 'package:vita_log/models/registro.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  List<Color> colors = [Colors.amber, Colors.green, Colors.blue, Colors.red];

  @override
  Widget build(BuildContext context) {
    final HiveRegistroController hiveRegistroController =
        HiveRegistroController(context: context);

    final List<Registro> registros = hiveRegistroController.fetch();

    final Map<String, int> countByType = {};

    for (var e in registros) {
      countByType[e.type] = (countByType[e.type] ?? 0) + 1;
    }

    final data = countByType.entries.map((e) {
      return {'type': e.key, 'value': e.value};
    }).toList();

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
        centerSpaceRadius: 40,
        sections: [
          for (var i in data)
            PieChartSectionData(
              color: colors[data.indexOf(i)],
              value: (double.tryParse(i['value'].toString())) ?? 0,
              title: ((double.tryParse(i['value'].toString()) ?? 0)
                  .round()
                  .toString()),
              titleStyle: AppStyle.headline.copyWith(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
