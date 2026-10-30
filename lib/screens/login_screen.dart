import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/api_config.dart';
import '../main.dart';
import '../services/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  static const _blue = Color(0xFF1B4F8A);
  static const _canvas = Color(0xFFF4F6F9);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _link = Color(0xFF2B6CB0);
  static const _btn = Color(0xFF1B4F8A);
  static const _border = Color(0xFFE2E8F0);

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
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
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return;
      }

      String message = 'Erreur de connexion';
      if (data is Map && data['erreur'] != null) {
        final err = data['erreur'];
        message = err is Map ? (err['message']?.toString() ?? message) : err.toString();
      }
      setState(() => _errorMessage = message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de joindre l\'API (${ApiConfig.baseUrl}). Vérifiez que le serveur tourne.';
      });
    }
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFFACB5BB), fontSize: 14, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _link, width: 1.4),
      ),
      suffixIcon: suffix,
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _muted,
          letterSpacing: -0.02 * 12,
        ),
      ),
    );
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _canvas,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/bcmm.png',
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      'BCMM',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Connexion',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            letterSpacing: -0.64,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Compte BCMM créé en interne',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: _muted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel('Nom d\'utilisateur'),
                        TextField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1A1C1E)),
                          decoration: _fieldDecoration(hint: 'admin'),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Mot de passe'),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1A1C1E)),
                          decoration: _fieldDecoration(
                            hint: '••••••••',
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: const Color(0xFFACB5BB),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                side: const BorderSide(color: _muted, width: 1.5),
                                activeColor: _btn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Se souvenir',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _muted),
                            ),
                            const Spacer(),
                            Text(
                              'Mot de passe oublié ?',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _link),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage.isNotEmpty) ...[
                          Text(
                            _errorMessage,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _btn,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _btn.withOpacity(0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                  )
                                : Text(
                                    'Se connecter',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
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
      ),
    );
  }
}
