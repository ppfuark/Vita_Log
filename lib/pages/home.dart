import 'package:flutter/material.dart';
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
        child: Column(children: [
        
        ],),
      ),
    );
  }
}
