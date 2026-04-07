import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vita_log/app_style.dart';
import 'package:vita_log/controller/hive_registro_controller.dart';
import 'package:vita_log/models/registro.dart';
import 'package:vita_log/pages/widgets/bar_chart_widget.dart';
import 'package:vita_log/pages/widgets/new_registro.dart';
import 'package:vita_log/pages/widgets/pie_chart_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final HiveRegistroController hiveRegistroController =
        HiveRegistroController(context: context);
    final List<Registro> registros = hiveRegistroController.fetch();

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 20,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppStyle.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(Icons.person, size: 30, color: Colors.white),
            ),
            Text(
              "VitaLog",
              style: AppStyle.display.copyWith(color: AppStyle.primary),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.deepPurple),
        onPressed: () {
          showDialog(context: context, builder: (context) => NewRegistro());
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: registros.isEmpty
            ? Center(
                child: Text("Nenhum registro ainda.", style: AppStyle.title),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: h * .3,
                        width: w * .45,
                        child: PieChartWidget(),
                      ),
                      SizedBox(
                        height: h * .3,
                        width: w * .45,
                        child: BarChartWidget(),
                      ),
                    ],
                  ),
                  Text(
                    'Histórico',
                    style: AppStyle.display.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: h * .5,
                    width: w,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final e = registros[index];
                        final emoji = [
                          '😭',
                          '😞',
                          '😥',
                          '😐',
                          '😊',
                          '😄',
                        ][e.humorLevel.round().clamp(0, 5)];

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            spacing: 30,
                            children: [
                              e.imagePath != null && e.imagePath != ''
                                  ? Image.file(
                                      File(e.imagePath!),
                                      fit: BoxFit.cover,
                                      width: 150,
                                      height: 150,
                                    )
                                  : Container(
                                      width: 150,
                                      height: 150,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.type.toUpperCase(),
                                      style: AppStyle.title.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Text(emoji, style: AppStyle.headline),
                                        SizedBox(width: 6),
                                        Text(
                                          e.humorLevel.toStringAsFixed(0),
                                          style: AppStyle.title,
                                        ),
                                      ],
                                    ),
                                    if (e.note != null && e.note!.isNotEmpty)
                                      Text(
                                        e.note!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyle.title.copyWith(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: registros.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
