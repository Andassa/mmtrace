import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart'; // Assurez-vous d'importer MainScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false; // Indicateur de chargement

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Affichez un indicateur de chargement
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.88.69:3000/sendDatalogin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'User-Agent': 'Flutter',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false; // Arrêtez l'indicateur de chargement
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('redirect')) {
          // Redirection vers MainScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else if (data.containsKey('erreur')) {
          setState(() {
            _errorMessage = data['erreur']['message'] ?? 'Erreur inconnue';
          });
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['erreur']?['message'] ?? 'Erreur inconnue';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Assurez-vous d'arrêter l'indicateur de chargement
        _errorMessage = 'Erreur réseau: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator() // Indicateur de chargement
            else
              ElevatedButton(
                onPressed: _login,
                child: Text('Se connecter'),
              ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
