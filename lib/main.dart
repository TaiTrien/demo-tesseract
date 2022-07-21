import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'OCR App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TextBlock> results = [];
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  late InputImage inputImage;
  File? pickedFile;
  bool loading = false;

  Future<void> processImage() async {
    try {
      var pickedImg = await pickFile();
      if (pickedImg == null) return;
      setState(() {
        loading = true;
      });

      inputImage = InputImage.fromFilePath(pickedImg.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        results = recognizedText.blocks;
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != '') {
      File file = File(result.files.single.path as String);
      setState(() {
        pickedFile = file;
      });
      return file;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Column(
              children: <Widget>[
                const Text(
                  'Your ID card',
                  style: TextStyle(fontSize: 22),
                ),
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(top: 5, bottom: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: pickedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            pickedFile as File,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(),
                ),
                const Text(
                  'Results',
                  style: TextStyle(fontSize: 22),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: loading == true
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ...results.map(
                              (e) => Text(
                                e.text,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: processImage,
        tooltip: 'Increment',
        child: const Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
