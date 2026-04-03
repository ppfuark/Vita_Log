import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vita_log/models/config.dart';

class HiveConfigController {
  final BuildContext context;
  final Function fetchData;

  HiveConfigController({required this.context, required this.fetchData});

  final hiveBoxConfig = Hive.box('vita_log_config');

  List<Config> fetch() {
    return hiveBoxConfig.keys
        .map((key) {
          final item = hiveBoxConfig.get(key) as Map<String, dynamic>;

          return Config.fromMap(item);
        })
        .toList()
        .reversed
        .toList();
  }

  Future<void> createConfig({required Config config}) async {
    try {
      await hiveBoxConfig.add(config.toMap());
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Config criado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na criação de Config!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }

  Future<void> editConfig({required Config config, required int key}) async {
    try {
      await hiveBoxConfig.put(key, config.toMap());
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Config editado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na edição de Config!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }

  Future<void> deleteConfig({required int key}) async {
    try {
      await hiveBoxConfig.delete(key);
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Config deletado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na remoção de Config!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }

  Future<void> clearConfig() async {
    try {
      await hiveBoxConfig.clear();
      fetch();
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Configs limpos com sucesso!'),
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na limpeza de Configs!'),
                backgroundColor: Colors.red,
              ),
            )
          : null;
    }
  }
}
