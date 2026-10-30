import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/api_config.dart';
import '../main.dart';
import '../services/api_client.dart';
import '../theme/bcmm_theme.dart';

/// Login institutionnel (pattern OpenGov / UX4G) : écran plein, formulaire direct.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Identifiant et mot de passe requis.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiClient.instance.post('/sendDatalogin', {
        'username': username,
        'password': password,
      });
      if (!mounted) return;
      setState(() => _isLoading = false);

      final dynamic data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode == 200 && data is Map && data['redirect'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
        return;
      }

      var message = 'Identifiants incorrects ou compte non validé.';
      if (data is Map && data['erreur'] != null) {
        final err = data['erreur'];
        message = err is Map ? (err['message']?.toString() ?? message) : err.toString();
      }
      setState(() => _errorMessage = message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Serveur injoignable (${ApiConfig.baseUrl}).';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bcmm.card,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            children: [
              Image.asset(
                'assets/images/bcmm.png',
                height: 40,
                alignment: Alignment.centerLeft,
                errorBuilder: (_, __, ___) => Text(
                  'BCMM',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Bcmm.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mineral Mapping',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: Bcmm.muted,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Connexion',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Bcmm.title,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Réservé aux comptes internes BCMM.',
                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: Bcmm.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              Text(
                'Identifiant',
                style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: Bcmm.body),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(hintText: 'ex. admin'),
              ),
              const SizedBox(height: 16),
              Text(
                'Mot de passe',
                style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: Bcmm.body),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Afficher' : 'Masquer',
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: Bcmm.muted,
                    ),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage,
                  style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Bcmm.danger, height: 1.35),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
