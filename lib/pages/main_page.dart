import 'package:flutter/material.dart';
import 'package:vita_log/pages/home_page.dart';
import 'package:vita_log/pages/record_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIdx = 0;
  final widgets = [HomePage(), RecordPage()];

  @override
  Widget build(BuildContext context) {
    // final w = MediaQuery.of(context).size.width;
    // final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: widgets[currentIdx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIdx,
        onTap: (value) {
          setState(() {
            currentIdx = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Recording'),
        ],
      ),
    );
  }
}
