import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vita_log/app_style.dart';
import 'package:vita_log/controller/hive_registro_controller.dart';
import 'package:vita_log/models/registro.dart';

class NewRegistro extends StatefulWidget {
  const NewRegistro({super.key});

  @override
  State<NewRegistro> createState() => _NewRegistroState();
}

class _NewRegistroState extends State<NewRegistro> {
  String? type;
  final List<String> typeOptions = ['corrida', 'caminhada', 'outro'];
  double humorLevel = 0;
  final note = TextEditingController();
  final steps = TextEditingController();

  dynamic camera;
  late CameraController cameraController;
  XFile? imageFile;
  bool showCam = false;

  void create() async {
    if (type == null || note.text.isEmpty || steps.text.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alguns campos estão vazios. Tente novamente.',
            style: AppStyle.title.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final HiveRegistroController hiveRegistroController =
          HiveRegistroController(context: context);

      hiveRegistroController.createRegistro(
        registro: Registro(
          type: type!,
          humorLevel: humorLevel,
          steps: int.parse(steps.text),
          note: note.text,
          imagePath: imageFile != null ? imageFile!.path : "",
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, 'home/', (routes) => false);
    }
  }

  void startApp() async {
    steps.text = '0';

    final cameras = await availableCameras();
    camera = cameras.first;

    cameraController = CameraController(camera, ResolutionPreset.max);
    cameraController.initialize();
  }

  void takePicture() async {
    try {
      final XFile picture = await cameraController.takePicture();
      setState(() {
        imageFile = picture;
        showCam = false;
      });
    } catch (e) {
      print("Erro new_registro: $e");
    }
  }

  @override
  void initState() {
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return showCam
        ? Stack(
            children: [
              Positioned.fill(child: CameraPreview(cameraController)),
              Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Padding(
                  padding: EdgeInsetsGeometry.only(bottom: 40),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: IconButton(
                      onPressed: () {
                        takePicture();
                      },
                      icon: Icon(Icons.camera, color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ],
          )
        : AlertDialog(
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
                      width: 260,
                      dropdownMenuEntries: [
                        for (var i in typeOptions)
                          DropdownMenuEntry(value: i, label: i.toUpperCase()),
                      ],
                      onSelected: (value) {
                        setState(() {
                          type = value!;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Registre uma foto ou áudio: ", style: AppStyle.title),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              showCam = true;
                            });
                          },
                          icon: Icon(Icons.camera_alt),
                        ),
                      ],
                    ),
                    if (imageFile != null)
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Image.file(File(imageFile!.path)),
                              ),
                            );
                          },
                          child: Image.file(
                            File(imageFile!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nível de humor: ", style: AppStyle.title),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoSlider(
                          value: humorLevel,
                          max: 5,
                          onChanged: (v) {
                            setState(() {
                              humorLevel = v.round().toDouble();
                            });
                          },
                        ),
                        humorLevel == 0
                            ? Text('😭')
                            : humorLevel == 1
                            ? Text('😞')
                            : humorLevel == 2
                            ? Text('😥')
                            : humorLevel == 3
                            ? Text('😐')
                            : humorLevel == 4
                            ? Text('😊')
                            : Text('😄'),
                      ],
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            int stepsInt = int.parse(steps.text.toString());
                            stepsInt--;
                            setState(() {
                              stepsInt < 0
                                  ? steps.text = '0'
                                  : steps.text = stepsInt.toString();
                            });
                          },
                          icon: Icon(Icons.minimize),
                        ),
                        SizedBox(
                          width: 15,
                          child: TextField(controller: steps),
                        ),
                        IconButton(
                          onPressed: () {
                            int stepsInt = int.parse(steps.text.toString());
                            stepsInt++;
                            setState(() {
                              steps.text = stepsInt.toString();
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    create();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Center(
                      child: Text(
                        "Salvar Registro",
                        style: AppStyle.title.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
