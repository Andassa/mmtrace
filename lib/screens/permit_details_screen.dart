import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PermitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> permitData;

  PermitDetailsScreen({required this.permitData});

  @override
  _PermitDetailsScreenState createState() => _PermitDetailsScreenState();
}

class _PermitDetailsScreenState extends State<PermitDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _permitHolder;
  late String _permitType;
  late String _shapeArea;

  @override
  void initState() {
    super.initState();
    _permitHolder = widget.permitData['registre_1'];
    _permitType = widget.permitData['type_tit_1'];
    _shapeArea = widget.permitData['shape_area'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Permit Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permit Information',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField(
                        'Permit Holder',
                        _permitHolder,
                            (value) {
                          _permitHolder = value;
                        },
                        'Enter the name of the permit holder.',
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        'Permit Type',
                        _permitType,
                            (value) {
                          _permitType = value;
                        },
                        'Specify the type of permit.',
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        'Shape Area',
                        _shapeArea,
                            (value) {
                          _shapeArea = value;
                        },
                        'Enter the area of the permit in square meters.',
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _showModifyConfirmation(context);
                            }
                          },
                          child: Text('Modify Permit Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onSaved, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: initialValue),
          onChanged: onSaved,
        ),
        SizedBox(height: 4),
      ],
    );
  }

  void _showModifyConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify Permit'),
          content: Text('Changes have been saved successfully.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
