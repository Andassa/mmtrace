import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:image/image.dart' as img;

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

      var output = List.filled(2, 0.0).reshape([1, 2]);

      var inputBuffer = inputImage.buffer.asUint8List();
      var inputShape = [1, inputImage.getHeight(), inputImage.getWidth(), 3];

      _interpreter.run(inputBuffer.reshape(inputShape), output);
      print('Output after running model: $output');

      _processOutput(output);
    } catch (e) {
      print('Error running model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite lors du traitement de l\'image.')),
      );
    }
  }

  TensorImage _preProcessImage(File image, int inputSize) {
    img.Image? originalImage = img.decodeImage(File(image.path).readAsBytesSync());

    if (originalImage == null) {
      throw Exception("Failed to decode image");
    }

    print('Original Image Size: ${originalImage.width} x ${originalImage.height}');

    img.Image resizedImage = img.copyResize(originalImage, width: inputSize, height: inputSize);
    print('Resized Image Size: ${resizedImage.width} x ${resizedImage.height}');

    TensorImage tensorImage = TensorImage.fromImage(resizedImage);

    var imageProcessor = ImageProcessorBuilder()
        .add(NormalizeOp(0, 255))
        .build();

    tensorImage = imageProcessor.process(tensorImage);

    print('Processed TensorImage buffer: ${tensorImage.buffer.asUint8List().length} bytes');
    print('TensorImage size: ${tensorImage.getHeight()} x ${tensorImage.getWidth()}');

    return tensorImage;
  }

  void _processOutput(List<dynamic> output) {
    print('Output before processing: $output');
    if (output.isNotEmpty && output[0] is List && output[0][0] is double) {
      List<double> outputValues = List<double>.from(output[0]); // Accédez directement au tableau de sortie
      int predictedIndex = outputValues.indexOf(outputValues.reduce(max));
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
