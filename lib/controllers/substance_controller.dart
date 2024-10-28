import 'package:flutter/material.dart';

class SubstanceController with ChangeNotifier {
  final List<String> _substances = [];

  List<String> get substances => _substances;

  void addSubstance(String substance) {
    _substances.add(substance);
    notifyListeners();
  }
}
