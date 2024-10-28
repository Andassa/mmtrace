import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? get userId => _userId;

  String? _userName;
  String? get userName => _userName;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Log in the user
  Future<void> login(String id, String name) async {
    _userId = id;
    _userName = name;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Log out the user
  Future<void> logout() async {
    _userId = null;
    _userName = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
