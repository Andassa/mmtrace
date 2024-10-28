import 'package:flutter/material.dart';
import 'package:mmtrace/ data/models/permit_model.dart';
import 'package:mmtrace/ data/repositories/permit_repository.dart';

class PermitProvider extends ChangeNotifier {
 /* final PermitRepository _permitRepository;

  List<Permit> _permits = [];
  List<Permit> get permits => _permits;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PermitProvider(this._permitRepository);

  /// Fetch permits from the repository
  Future<void> fetchPermits() async {
    _isLoading = true;
    notifyListeners();
    try {
      _permits = await _permitRepository.fetchPermits();
    } catch (error) {
      print('Error fetching permits: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new permit
  Future<void> addPermit(Permit permit) async {
    try {
      await _permitRepository.createPermit(permit);
      _permits.add(permit);
      notifyListeners();
    } catch (error) {
      print('Error adding permit: $error');
    }
  }

  /// Update an existing permit
  Future<void> updatePermit(Permit permit) async {
    try {
      await _permitRepository.updatePermit(permit);
      int index = _permits.indexWhere((p) => p.id == permit.id);
      if (index != -1) {
        _permits[index] = permit;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating permit: $error');
    }
  }

  /// Delete a permit
  Future<void> deletePermit(String permitId) async {
    try {
      await _permitRepository.deletePermit(permitId);
      _permits.removeWhere((permit) => permit.id == permitId);
      notifyListeners();
    } catch (error) {
      print('Error deleting permit: $error');
    }
  }

  */
}
