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
      print('Loading model...');
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      print('Model loaded successfully.');

      String labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').map((label) => label.trim()).toList();
      print('Labels loaded: ${_labels.length}');
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
      print('Image captured: ${pickedFile.path}');
      await _runModelOnImage(_image!);
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      print('Image selected: ${pickedFile.path}');
      await _runModelOnImage(_image!);
    }
  }

  Future<void> _runModelOnImage(File image) async {
    try {
      print('Preprocessing image...');
      var inputImage = _preProcessImage(image, 224);
      print('Image preprocessed. Dimensions: ${inputImage.getHeight()}x${inputImage.getWidth()}');

      var output = List.filled(2, 0.0).reshape([1, 2]);
      var inputBuffer = inputImage.buffer.asUint8List();
      var inputShape = [1, inputImage.getHeight(), inputImage.getWidth(), 3];

      print('Running model...');
      _interpreter.run(inputBuffer.reshape(inputShape), output);
      print('Model run complete. Output: $output');

      _processOutput(output);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite lors du traitement de l\'image.')),
      );
      print('Error during model processing: $e');
    }
  }

  TensorImage _preProcessImage(File image, int inputSize) {
    img.Image? originalImage = img.decodeImage(File(image.path).readAsBytesSync());
    if (originalImage == null) throw Exception("Failed to decode image");

    img.Image resizedImage = img.copyResize(originalImage, width: inputSize, height: inputSize);
    TensorImage tensorImage = TensorImage.fromImage(resizedImage);
    var imageProcessor = ImageProcessorBuilder().add(NormalizeOp(0, 255)).build();
    return imageProcessor.process(tensorImage);
  }

  void _processOutput(List<dynamic> output) {
    if (output.isNotEmpty && output[0] is List && output[0][0] is double) {
      List<double> outputValues = List<double>.from(output[0]);
      print('Output values: $outputValues');

      double maxConfidence = outputValues.reduce(max);
      int predictedIndex = outputValues.indexOf(maxConfidence);
      print('Max confidence: $maxConfidence, Predicted index: $predictedIndex');

      setState(() {
        _substanceNameController.text = maxConfidence < 0.7
            ? 'Substance non reconnue'
            : (_labels[predictedIndex] ?? 'Inconnu');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire de Substances', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1976D2), // Palette de couleurs de HomeScreen
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF1976D2), width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: _image == null
                  ? Center(child: Text('Aucune image sélectionnée.', style: TextStyle(color: Colors.grey, fontSize: 16)))
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _substanceNameController,
              label: 'Nom de la Substance',
              readOnly: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Lieu',
            ),
            SizedBox(height: 20),
            _buildElevatedButton(
              onPressed: _captureImage,
              icon: Icons.camera_alt,
              label: 'Capturer une image',
            ),
            SizedBox(height: 10),
            _buildElevatedButton(
              onPressed: _selectImage,
              icon: Icons.photo_library,
              label: 'Sélectionner une image',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      readOnly: readOnly,
      style: TextStyle(color: Colors.black87),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white), // Couleur de l'icône
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 16), // Couleur et taille du texte
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1976D2), // Palette de couleurs de HomeScreen
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
