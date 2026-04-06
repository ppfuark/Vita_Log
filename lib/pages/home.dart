import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vita_log/controller/hive_registro_controller.dart';
import 'package:vita_log/models/registro.dart';
import 'package:vita_log/pages/widgets/new_registro.dart';

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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.deepPurple),
        onPressed: () {
          showDialog(context: context, builder: (context) => NewRegistro());
        },
      ),
      body: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(),
        child: Column(
          children: [
            SizedBox(
              height: h * .9,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final e = registros[index];
                  return ListTile(
                    leading: e.imagePath != null && e.imagePath != ''
                        ? Image.file(File(e.imagePath!))
                        : null,
                    title: Text(e.type),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.humorLevel.toString()),
                        e.humorLevel == 0
                            ? Text('😭')
                            : e.humorLevel == 1
                            ? Text('😞')
                            : e.humorLevel == 2
                            ? Text('😥')
                            : e.humorLevel == 3
                            ? Text('😐')
                            : e.humorLevel == 4
                            ? Text('😊')
                            : Text('😄'),
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
