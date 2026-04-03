import 'package:flutter/material.dart';
import 'package:vita_log/app_style.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? type;
  final List<String> typeOptions = ['corrida', 'caminhada', 'outro'];
  double humorLevel = 0;
  final note = TextEditingController();
  DateTime? timestamp;
  final steps = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.deepPurple),
        onPressed: () {
          setState(() {
            steps.text = '0';
          });
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    title: Text("Novo Registro ", style: AppStyle.headline),
                    content: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tipo de Registro: ", style: AppStyle.title),
                            DropdownMenu(
                              width: 230,
                              dropdownMenuEntries: [
                                for (var i in typeOptions)
                                  DropdownMenuEntry(
                                    value: i,
                                    label: i.toUpperCase(),
                                  ),
                              ],
                              onSelected: (value) {
                                setDialogState(() {
                                  type = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nível de humor: ", style: AppStyle.title),

                            Slider(
                              value: humorLevel,
                              max: 5,
                              onChanged: (v) {
                                setDialogState(() {
                                  humorLevel = v.round().toDouble();
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Anotações: ", style: AppStyle.title),

                            TextField(
                              controller: note,
                              minLines: 5,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'Nesse dia eu...',
                                // border: OutlineInputBorder()
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Anotações: ", style: AppStyle.title),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    int stepsInt = int.parse(
                                      steps.text.toString(),
                                    );
                                    stepsInt--;
                                    setDialogState(() {
                                      stepsInt < 0
                                          ? steps.text = '0'
                                          : steps.text = stepsInt.toString();
                                    });
                                  },
                                  icon: Icon(Icons.minimize),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: TextField(controller: steps),
                                ),
                                IconButton(
                                  onPressed: () {
                                    int stepsInt = int.parse(
                                      steps.text.toString(),
                                    );
                                    stepsInt++;
                                    setDialogState(() {
                                      steps.text = stepsInt.toString();
                                    });
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
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
