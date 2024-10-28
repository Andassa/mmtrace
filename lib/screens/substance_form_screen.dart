import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> data = ['Substance 1', 'Substance 2', 'Substance 3', 'Substance 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubstanceFormScreen()),
              );
            },
          );
        },
      ),
    );
  }
}

class SubstanceFormScreen extends StatefulWidget {
  @override
  _SubstanceFormScreenState createState() => _SubstanceFormScreenState();
}

class _SubstanceFormScreenState extends State<SubstanceFormScreen> {
  File? _image;
  final picker = ImagePicker();
  late Interpreter _interpreter;
  TextEditingController _substanceNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      String labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').map((label) => label.trim()).toList();
      print('Loaded labels: $_labels');
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _runModelOnImage(_image!);
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _runModelOnImage(_image!);
    }
  }

  Future<void> _runModelOnImage(File image) async {
    try {
      var inputImage = _preProcessImage(image, 224);
      print('Input Image Size: ${inputImage.getHeight()} x ${inputImage.getWidth()}');

      var output = List.filled(_labels.length, 0).reshape([1, _labels.length]);

      // Assurez-vous que le tableau d'entrée a la bonne forme
      if (inputImage.getHeight() == 224 && inputImage.getWidth() == 224) {
        _interpreter.run(inputImage.buffer.asUint8List(), output);
        print('Output after running model: $output');
        _processOutput(output);
      } else {
        print('Invalid input size: ${inputImage.getWidth()} x ${inputImage.getHeight()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La taille de l\'image d\'entrée est invalide.')),
        );
      }
    } catch (e) {
      print('Error running model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite lors du traitement de l\'image.')),
      );
    }
  }

  TensorImage _preProcessImage(File image, int inputSize) {
    // Chargez l'image depuis le fichier
    TensorImage tensorImage = TensorImage.fromFile(image);
    var imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.nearestneighbour))
        .add(NormalizeOp(0, 255)) // Normalisation, ajustez selon les besoins de votre modèle
        .build();

    tensorImage = imageProcessor.process(tensorImage);
    return tensorImage;
  }

  void _processOutput(List output) {
    print('Output before processing: $output');
    if (output.length == 1 && output[0].length == _labels.length) {
      int predictedIndex = output[0].indexOf(output[0].reduce(max));
      if (predictedIndex >= 0 && predictedIndex < _labels.length) {
        String substanceName = _labels[predictedIndex];
        setState(() {
          _substanceNameController.text = substanceName;
        });
        print('Predicted Substance: $substanceName');
      } else {
        print('Index out of range: $predictedIndex');
      }
    } else {
      print('Invalid output structure: $output');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Substance Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            TextField(
              controller: _substanceNameController,
              decoration: InputDecoration(labelText: 'Substance Name'),
              readOnly: true,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            ElevatedButton(
              onPressed: _captureImage,
              child: Text('Capture Image'),
            ),
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Select Image'),
            ),
          ],
        ),
      ),
    );
  }
}
