import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List? _outputs;
  File? image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Center(child: Text("detection")),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: EdgeInsets.all(60),
              width: 300,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  image == null
                      ? Container()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(image!),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  _outputs != null
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "It is ${_outputs![0]['label']}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 45.0,
                                backgroundColor: Colors.red),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.camera),
      ),
    );
  }

  Future pickImage() async {
    var saveimg = await ImagePicker().getImage(source: ImageSource.camera);
    if (saveimg == null) return null;
    setState(() {
      _loading = false;
      image = File(saveimg.path);
    });
    Image.file(image!);
    imageClassification(image!);
  }

  imageClassification(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _outputs = output!;
      _loading = false;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1);
  }
}
