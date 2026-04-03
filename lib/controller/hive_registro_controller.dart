import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vita_log/models/registro.dart';

class HiveRegistroController {
  final BuildContext context;
  final Function fetchData;

  HiveRegistroController({required this.context, required this.fetchData});

  final hiveBoxRegistro = Hive.box('vita_log_registro');

  List<Registro> fetch() {
    return hiveBoxRegistro.keys
        .map((key) {
          final item = hiveBoxRegistro.get(key) as Map<String, dynamic>;

          return Registro.fromMap(item);
        })
        .toList()
        .reversed
        .toList();
  }

  Future<void> createRegistro({required Registro registro}) async {
    try {
      await hiveBoxRegistro.add(registro.toMap());
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registro criado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na criação de Registro!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }

  Future<void> editRegistro({
    required Registro registro,
    required int key,
  }) async {
    try {
      await hiveBoxRegistro.put(key, registro.toMap());
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registro editado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na edição de Registro!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }

  Future<void> deleteRegistro({required int key}) async {
    try {
      await hiveBoxRegistro.delete(key);
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registro deletado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na remoção de Registro!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }

  Future<void> clearRegistro() async {
    try {
      await hiveBoxRegistro.clear();
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registros limpos com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na limpeza de Registros!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }
}
